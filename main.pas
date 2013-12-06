(****
 * 
 * Game pong in pascal based on GLUT
 * Start day - 29.11
 * 
 *)
program Pong;

uses glut_function;

var
	player1,player2 : String;
	speed: double;
	new: String;
begin
	writeln('You want to enter new data?(y/n)');
		readln(new);
	if (new = 'y') then
		begin
			writeln('Name of player 1:');
				readln(player1);
			writeln('Name of player2');
				readln(player2);
			writeln('Write value speed ball (0.0 - 1.0, eq. 0.6 - deflaut)');
				readln(speed);
		end
	else
		begin
			player1 := '';
			player2 := '';
			speed	:= 0.6;
		end;

	main(player1,player2,speed);

end.