UNIT glut_function;

{**
 * Game Pong v0.1
 * author Paweł Gnych
 *}

INTERFACE

	uses gl, glut, glu;
	
	const
		FSMode = '1366x768:32@75';
		path = '/home/pablo/Projects/pong/settings.pong';
	type
		kepress = array [byte] of boolean; {* array all keys *}
		
		ballVector = record
			x,y: double;	{* position ball *}
		end;

		settingsRecord = record 
			speed 										: double; 		{* range 0 - 1 *}
			player1_name, player2_name					: String; 		{* names of players *}
			player1_point, player2_point, max_points 	: byte; 		{* points players *}
		end;

{**
 * Globals variable
 *}

	var
		keyboardpress 						: kepress;		{* array with pressed keys *}
		specialkeyboardpress 				: kepress;		{* array with pressed special keys *}
		start, endGame, loadedSettings		: boolean;		{* flags game *}
		position1, position2  				: double;		{* position1 - position player1, position2 - position player2 *}
		angle 								: double;   	{* angle reflection ball *}
		ball 								: ballVector;	{* position ball and speed *}
		fileSettings						: file of settingsRecord;
		settings 							: settingsRecord;

	procedure glutInitPascal(parse : boolean);

	procedure InitializeGL();

	procedure EngineBall();

	procedure Reset_Game();

	procedure glWrite(X, Y: GLfloat; Font: Pointer; Text: String);

	procedure loadSettingsFromFile(default:boolean);

	procedure saveSettingsToFile();

	procedure ControlGame();

	procedure DrawGLScene(); cdecl;

	procedure ReSizeGLScene(Width, Height: Longint); cdecl;

	procedure GLKeyboard(key : byte; x, y : longint); cdecl;

	procedure GLKeyboardSpecial(key, x, y : longint); cdecl;

	procedure GLKeyboardUp(Key: Byte; X, Y: Longint); cdecl;

	procedure GLKeyboardUpSpecial(Key, X, Y: Longint); cdecl;

	procedure main(name1,name2:String; ballSpeed: double);


IMPLEMENTATION

{**
 * Initialize glut pascal
 *}
	procedure glutInitPascal(parse : boolean);
		var
			argv  : array of pchar;
			s 	  : AnsiString;
			argc  : integer;
			index : integer;
		begin
			if parse then
				argc := ParamCount + 1
			else
				argc := 1;
			SetLength(argv, argc);
			for index := 0 to argc - 1 do
			begin
				s := ParamStr(index);
				argv[index] := pchar(s);
			end;
			glutInit(@argc, @argv);
		end;
{**
 * Clear display
 *}
	procedure InitializeGL();
		begin
			glClearColor(0, 0, 0, 0);
		end;
{**
 * Generate text
 *}

	procedure glWrite(X, Y: GLfloat; Font: Pointer; Text: String);
		var
		  I: Integer;
		begin
		  glRasterPos2f(X, Y);
			  for I := 1 to Length(Text) do
			    glutBitmapCharacter(Font, Integer(Text[I]));
		end;

{**
 * Load settings form file or clear score to default
 *}

	procedure loadSettingsFromFile(default:boolean);
		begin
			if (default = false) then
				begin
					settings.player1_point	:= 0;
					settings.player2_point	:= 0;
					settings.max_points		:= 10;
				end
			else
				begin
					assign(fileSettings, path);
					reset(fileSettings);

					while (not Eof(fileSettings)) do
					begin
						read(fileSettings,settings);
					end;
					close(fileSettings);
				end;
		end;
{**
 * Save setting to file 
 *}
	procedure saveSettingsToFile();
		begin
			assign(fileSettings, path);
			rewrite(fileSettings);
				write(fileSettings,settings);
			close(fileSettings);
		end;

{**
 * Making move ball
 *}
	procedure EngineBall();
		begin

			if endGame = false then
				begin
					ball.x := ball.x + (cos(angle) * settings.speed);
					ball.y := ball.y + (sin(angle) * settings.speed);
				end;

			if (ball.y <= -25) OR (ball.y >= 25) then
				begin
					angle := 2 * Pi - angle;
				end;

			if (ball.x <= -49) then
				begin
					if (ball.y > position1 - 2.5) AND (ball.y < position1 + 2.5) then
							angle := Pi - angle
					else 
						if (ball.y >= position1 + 2.5) AND (ball.y <= position1 + 5) then
							angle := Pi - angle + 0.3
						else 
							if (ball.y >= position1 - 5) AND (ball.y <= position1 -2.5) then
								angle := Pi - angle - 0.3
							else
								begin
									settings.player1_point := settings.player1_point + 1;
									Reset_Game();
								end;
				end;

			if (ball.x >= 49) then
				begin
					if (ball.y > position2 - 2.5) AND (ball.y < position2 + 2.5) then
							angle := Pi - angle
					else 
						if (ball.y >= position2 + 2.5) AND (ball.y <= position2 + 5) then
							angle := Pi - angle + 0.3
						else 
							if (ball.y >= position2 - 5) AND (ball.y <= position2 -2.5) then
								angle := Pi - angle - 0.3
							else
								begin
									settings.player2_point := settings.player2_point + 1;
									Reset_Game();
								end;
				end;

		end;

{**
 * set ball on (0,0) and players to 0
 *}
	procedure Reset_Game();
		begin

			ball.x:= 0;
			ball.y:= 0;

			position1 := 0;
			position2 := 0;

			start := false;

			angle := Pi / 180 * 45;  {* angle on start*} 
		end;

{**
 * Controler all pressed keys
 *}
	procedure ControlGame();
		begin
			if (keyboardpress[97] = TRUE) AND (position1 < 20) then
		  		position1 := position1 + 0.5;

		  	if (keyboardpress[122] = TRUE) AND (position1 > -20) then
		  		position1 := position1 - 0.5;

		  	if (specialkeyboardpress[GLUT_KEY_UP] = TRUE) AND (position2 < 20) then
		  		position2 := position2 + 0.5;		  	

		  	if (specialkeyboardpress[GLUT_KEY_DOWN] = TRUE) AND (position2 > -20) then
		  		position2 := position2 - 0.5;

		  	if (keyboardpress[32] = true) then
		  		begin
		  			start := true;
		  		end;

		  	if (keyboardpress[107] = true) then
		  		begin
		  			saveSettingsToFile();
		  		end;

		  	if (keyboardpress[108] = true) then
		  		begin
		  			loadSettingsFromFile(true);
		  		end;


		end;
{**
 * Generated string from score game
 *}
	function generateScore():String;
		var
			player1_str,player2_str,response: String;
		
		begin
			if (settings.player1_point = settings.max_points) or (settings.player2_point = settings.max_points) then
				endGame := true;
			
			str(settings.player1_point,player1_str);
			str(settings.player2_point,player2_str);

			response := settings.player1_name + ' - ' + player1_str + ' : ' + player2_str + ' - ' + settings.player2_name;
			
			generateScore := response;

		end;

{**
 * Drwaing all objects in the game
 *}
	procedure DrawGLScene(); cdecl;
		var 
			winner: String;
		begin

		  	glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
		  	
		  	if start = false then
		  		Reset_Game()
		  	else
		  		begin
					EngineBall();
				end;

		  	ControlGame();

			glPushMatrix;
				glTranslatef(ball.x, ball.y, 0);
				glColor3f(1, 1, 1);
				glutSolidSphere(0.5, 10, 10);
			glPopMatrix;

			glBegin(GL_LINES);
				glColor3f(1, 1, 1);
				glVertex3f(50, -25, 0);

				glColor3f(1, 1, 1);
				glVertex3f(-50, -25, 0);
			glEnd;

			glBegin(GL_LINES);
				glColor3f(1, 1, 1);
				glVertex3f(50, 25, 0);

				glColor3f(1, 1, 1);
				glVertex3f(-50, 25, 0);
			glEnd;

		    glBegin(GL_LINES);
		      glColor3f(1, 1, 1);
		      glVertex3f(-49, 5 + position1, 0);
		 
		      glColor3f(1, 1, 1);
		      glVertex3f(-49, -5 + position1, 0);
		    glEnd;

		    glBegin(GL_LINES);
		      glColor3f(1, 1, 1);
		      glVertex3f(49, 5 + position2, 0);
		 
		      glColor3f(1, 1, 1);
		      glVertex3f(49, -5 + position2, 0);
		    glEnd;

			glColor3f(1, 1, 1);
			glWrite(-50, -30, GLUT_BITMAP_9_BY_15, '"space" - start game, "ESC" - exit, "k" - save game to file, "l" - load game form file');

			glColor3f(1, 1, 1);
			glWrite(-12.5, -35, GLUT_BITMAP_TIMES_ROMAN_24, generateScore());

			if endGame = true then
				begin
					if (settings.player1_point = settings.max_points) then
						winner := 'Winner ' + settings.player1_name
					else
						winner := 'Winner ' + settings.player2_name;
					
					glColor3f(1, 0, 0);
					glWrite(-10, -40, GLUT_BITMAP_TIMES_ROMAN_24, winner);
				end;

		  glutSwapBuffers;

		end;

{**
 * ( function get form tutorial about glut)
 *}
	procedure ReSizeGLScene(Width, Height: Longint); cdecl;
		begin
			if height = 0 then height := 1;
			glViewport(0, 0, width, height);
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity;
			gluPerspective(90, width / height, 0.1, 1000);
			
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity;
			gluLookAt(0, 0, 50, 0, 0, 0, 0, 1, 0);

		end;

{**
 * Handler pressdown normal key
 *}
	procedure GLKeyboard(Key: Byte; X, Y: Longint); cdecl;
		begin

		  	if Key = 27 then
		  	begin
		  		glutLeaveGameMode;
   				Halt(0);
   			end;
			
			keyboardpress[Key] := TRUE;
		end;

{**
 * Handler pressdown special key
 *}
	procedure GLKeyboardSpecial(Key, X, Y: Longint); cdecl;
		begin
			specialkeyboardpress[Key] := TRUE;
		end;	

{**
 * Handler pressup normal key
 *}
	procedure GLKeyboardUp(Key: Byte; X, Y: Longint); cdecl;
		begin
			keyboardpress[Key] := False;
		end;

{**
 * Handler pressup special key
 *}
	procedure GLKeyboardUpSpecial(Key, X, Y: Longint); cdecl;
		begin
			specialkeyboardpress[Key] := False;
		end;

{**
 * main function - init all function
 *}
	procedure main(name1,name2:String; ballSpeed: double);
		begin
			
			loadSettingsFromFile(false);

			settings.player1_name 	:= name1;
			settings.player2_name 	:= name2;
			settings.speed 			:= ballSpeed;

			start := false;
			endGame := false;

			glutInitPascal(False);
			glutInitDisplayMode(GLUT_DOUBLE or GLUT_RGB or GLUT_DEPTH);
			glutGameModeString(FSMode);
			glutEnterGameMode;
			glutSetCursor(GLUT_CURSOR_NONE);

			InitializeGL;

			glutDisplayFunc(@DrawGLScene);
			glutReshapeFunc(@ReSizeGLScene);
			glutKeyboardFunc(@GLKeyboard);
			glutKeyboardUpFunc(@GLKeyboardUp);
			glutSpecialFunc(@GLKeyboardSpecial);
			glutSpecialUpFunc(@GLKeyboardUpSpecial);
			glutIdleFunc(@DrawGLScene);

			glutMainLoop;
		end;

end.