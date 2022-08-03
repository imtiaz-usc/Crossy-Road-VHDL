`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background,
	output reg [1:0] lives,
	output reg [3:0] score
   );
	wire block_fill;
	wire train_fill;
	wire finish_line;
	wire car1;
	wire car2;
	wire car3;
	wire train2;
	wire car4;
	wire car5;
	wire car6;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	
	// Finish line
	reg [9:0] finishx, finishy;
	
	// Obstacle #1
	reg [9:0] trainx, trainy;
	
	// Obstacle Set #2
	reg [9:0] car1x, car1y;
	reg [9:0] car2x, car2y;
	reg [9:0] car3x, car3y;
	
	// Obstacle #3
	reg [9:0] train2x, train2y;
	
	// Obstacle Set #4
	reg [9:0] car4x, car4y;
	reg [9:0] car5x, car5y;
	reg [9:0] car6x, car6y;
	
	// Flag for finish line
	reg finish_hit;
	
	// Flag to check collision with obstacle #1
	reg train_hit;
	
	// Flags for first set of cars
	reg car1_hit;
	reg car2_hit;
	reg car3_hit;
	
	// Flag for hitting train2
	reg train2_hit;
	
	// Flags for second set of cars
	reg car4_hit;
	reg car5_hit;
	reg car6_hit;
	
	// Flag for game over
	reg gameOver;
	
	// Keep traffic speed
	integer traffic_1;
	integer traffic_2;
	integer traffic_3;
	integer traffic_4;
	
	parameter TEAL = 12'b0000_1111_1111;
	parameter FERRARI_RED = 12'b1111_0000_0000;
	parameter PORSCHE_YELLOW = 12'b1111_1110_0000;
	parameter BUGATTI_PURPLE = 12'b1000_1000_1110;
	parameter GRAY = 12'b1000_1000_1000;
	parameter BLUE = 12'b0000_0000_1111;
	parameter GREEN   = 12'b0000_1111_0000;
	parameter BLACK = 12'b0000_0000_0000;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	
			rgb = BLACK;
		else if (block_fill) 
			rgb = BLUE;
		else if (train_fill)
			rgb = BUGATTI_PURPLE;
			/*
		else if (finish_line)
			rgb = GREEN;
			*/
		else if (car1)
			rgb = FERRARI_RED;
		else if (car2)
			rgb = FERRARI_RED;
		else if (car3)
			rgb = FERRARI_RED;
		else if (train2)
			rgb = GRAY;
		else if (car4)
			rgb = PORSCHE_YELLOW;
		else if (car5)
			rgb = PORSCHE_YELLOW;
		else if (car6)
			rgb = PORSCHE_YELLOW;
		else	
			rgb=background;
	end
	
	//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill= (((vCount>=(ypos-3) && vCount<=(ypos+3)) && (hCount>=(xpos-5) && hCount<=(xpos+5))) ||
                        ((vCount>=(ypos+4) && vCount<=(ypos+5)) && (hCount==(xpos-4) ||  hCount==(xpos+4))) || 
						((vCount>=(ypos-10) && vCount<=(ypos-8)) && (hCount>=(xpos-4) && hCount<=(xpos-1))) || 
                        ((vCount>=(ypos-8) && vCount<=(ypos-4)) && (hCount>=(xpos-4) && hCount<=(xpos+1))) ||
                        ((vCount>=(ypos+8) && vCount<=(ypos+7)) && ((hCount>=(xpos-5) && hCount<=(xpos-4)) || (hCount<=(xpos+4) && hCount>=(xpos+3)))) ||
                        ((vCount>=(ypos-6) && vCount<=(ypos-5)) && (hCount>=(xpos-7) && hCount<=(xpos-5)))
                        );
	
	//vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-5) && hCount<=(xpos+5);
	
	// dimensions of train
	assign train_fill= (((vCount>=(trainy+2) && vCount<=(trainy+5)) && (hCount>=(trainx-30) && hCount<=(trainx+30))) ||
						((vCount==(trainy+1)) && ((hCount>=(trainx-29) && hCount<=(trainx-24)) || (hCount>=(trainx-15) && hCount<=(trainx+30)))) ||
						((vCount==(trainy-1)) && ((hCount>=(trainx-28) && hCount<=(trainx-24)) || (hCount>=(trainx-15) && hCount<=(trainx+30)))) ||
						((vCount==(trainy-2)) && ((hCount>=(trainx-27) && hCount<=(trainx-24)) || (hCount>=(trainx-15) && hCount<=(trainx+30))))
						);
	
	//vCount>=(trainy-10) && vCount<=(trainy+10) && hCount>=(trainx-20) && hCount<=(trainx+20);
	
	// dimensions of finish line pad
	assign finish_line=vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-300) && hCount<=(xpos+300);
	
	// first set of cars in traffic
	assign car1=( (vCount>=(car1y-2) && vCount<=(car1y+2) && hCount>=(car1x-7) && hCount<=(car1x+7))||
                                  ((vCount >=(car1y-4) && vCount <= (car1y-2)) && (((hCount>=car1x-5)&&(hCount<=car1x+1)) || ((hCount>=car1x+4) && (hCount<=car1x+5)))) ||
                                  ((vCount>=(car1y-6) && vCount<=(car1y-5)) &&  (hCount>=(car1x-5) && hCount<=(car1x+5))) ||
                                  ((vCount>=(car1y+2) && vCount<=(car1y+4)) && ((hCount>=(car1x-7) && hCount<=(car1x-6)) || (hCount>=(car1x-3) && hCount<=(car1x+3)) || (hCount>=(car1x+6) && hCount<=(car1x+7))))  || 
                                  ((vCount>=(car1y+5) && vCount<=(car1y+6)) &&  ((hCount==(car1x-6)||hCount==(car1x-3)) || (hCount==(car1x+6)||hCount==(car1x+3)))) ||
                                  ((vCount>=(car1y+6) && vCount<=(car1y+7)) && ((hCount<=(car1x-4) && hCount>=(car1x-5)) ||(hCount>=(car1x+4) && hCount<=(car1x+5))))
                                        );
	assign car2=( (vCount>=(car2y-2) && vCount<=(car2y+2) && hCount>=(car2x-7) && hCount<=(car2x+7))||
                                  ((vCount >=(car2y-4) && vCount <= (car2y-2)) && (((hCount>=car2x-5)&&(hCount<=car2x+1)) || ((hCount>=car2x+4) && (hCount<=car2x+5)))) ||
                                  ((vCount>=(car2y-6) && vCount<=(car2y-5)) &&  (hCount>=(car2x-5) && hCount<=(car2x+5))) ||
                                  ((vCount>=(car2y+2) && vCount<=(car2y+4)) && ((hCount>=(car2x-7) && hCount<=(car2x-6)) || (hCount>=(car2x-3) && hCount<=(car2x+3)) || (hCount>=(car2x+6) && hCount<=(car2x+7))))  || 
                                  ((vCount>=(car2y+5) && vCount<=(car2y+6)) &&  ((hCount==(car2x-6)||hCount==(car2x-3)) || (hCount==(car2x+6)||hCount==(car2x+3)))) ||
                                  ((vCount>=(car2y+6) && vCount<=(car2y+7)) && ((hCount<=(car2x-4) && hCount>=(car2x-5)) ||(hCount>=(car2x+4) && hCount<=(car2x+5))))
                                        );
	assign car3=( (vCount>=(car3y-2) && vCount<=(car3y+2) && hCount>=(car3x-7) && hCount<=(car3x+7))||
                                  ((vCount >=(car3y-4) && vCount <= (car3y-2)) && (((hCount>=car3x-5)&&(hCount<=car3x+1)) || ((hCount>=car3x+4) && (hCount<=car3x+5)))) ||
                                  ((vCount>=(car3y-6) && vCount<=(car3y-5)) &&  (hCount>=(car3x-5) && hCount<=(car3x+5))) ||
                                  ((vCount>=(car3y+2) && vCount<=(car3y+4)) && ((hCount>=(car3x-7) && hCount<=(car3x-6)) || (hCount>=(car3x-3) && hCount<=(car3x+3)) || (hCount>=(car3x+6) && hCount<=(car3x+7))))  || 
                                  ((vCount>=(car3y+5) && vCount<=(car3y+6)) &&  ((hCount==(car3x-6)||hCount==(car3x-3)) || (hCount==(car3x+6)||hCount==(car3x+3)))) ||
                                  ((vCount>=(car3y+6) && vCount<=(car3y+7)) && ((hCount<=(car3x-4) && hCount>=(car3x-5)) ||(hCount>=(car3x+4) && hCount<=(car3x+5))))
                                        );
	
	// Train2 dimensions
	assign train2= (((vCount>=(train2y+2) && vCount<=(train2y+5)) && (hCount>=(train2x-60) && hCount<=(train2x+60))) ||
						((vCount==(train2y+1)) && ((hCount>=(train2x-58) && hCount<=(train2x-48)) || (hCount>=(train2x-30) && hCount<=(train2x+60)))) ||
						((vCount==(train2y-1)) && ((hCount>=(train2x-56) && hCount<=(train2x-48)) || (hCount>=(train2x-30) && hCount<=(train2x+60)))) ||
						((vCount==(train2y-2)) && ((hCount>=(train2x-54) && hCount<=(train2x-48)) || (hCount>=(train2x-30) && hCount<=(train2x+60))))
						);
	
	//vCount>=(train2y-5) && vCount<=(train2y+5) && hCount>=(train2x-60) && hCount<=(train2x+60);
	
	// second set of cars in traffic
	assign car4=( (vCount>=(car4y-4) && vCount<=(car4y+4) && hCount>=(car4x-14) && hCount<=(car4x+14))||
                                  ((vCount >=(car4y-8) && vCount <= (car4y-4)) && (((hCount>=car4x-10)&&(hCount<=car4x+2)) || ((hCount>=car4x+8) && (hCount<=car4x+10)))) ||
                                  ((vCount>=(car4y-12) && vCount<=(car4y-9)) &&  (hCount>=(car4x-10) && hCount<=(car4x+10))) ||
                                  ((vCount>=(car4y+4) && vCount<=(car4y+8)) && ((hCount>=(car4x-14) && hCount<=(car4x-12)) || (hCount>=(car4x-6) && hCount<=(car4x+6)) || (hCount>=(car4x+12) && hCount<=(car4x+14))))  || 
                                  ((vCount>=(car4y+8) && vCount<=(car4y+12)) &&  ((hCount==(car4x-12) || (hCount==(car4x-13))) || (hCount==(car4x-6) || (hCount==(car4x-5))) || ((hCount==(car4x+12) || (hCount==(car4x+13))) || (hCount==(car4x+6) || (hCount==(car4x+5)))))) ||
                                  ((vCount>=(car4y+12) && vCount<=(car4y+14)) && ((hCount<=(car4x-7) && hCount>=(car4x-11)) ||(hCount>=(car4x+7) && hCount<=(car4x+11))))
                                        );
										
	assign car5=( (vCount>=(car5y-4) && vCount<=(car5y+4) && hCount>=(car5x-14) && hCount<=(car5x+14))||
                                  ((vCount >=(car5y-8) && vCount <= (car5y-4)) && (((hCount>=car5x-10)&&(hCount<=car5x+2)) || ((hCount>=car5x+8) && (hCount<=car5x+10)))) ||
                                  ((vCount>=(car5y-12) && vCount<=(car5y-9)) &&  (hCount>=(car5x-10) && hCount<=(car5x+10))) ||
                                  ((vCount>=(car5y+4) && vCount<=(car5y+8)) && ((hCount>=(car5x-14) && hCount<=(car5x-12)) || (hCount>=(car5x-6) && hCount<=(car5x+6)) || (hCount>=(car5x+12) && hCount<=(car5x+14))))  || 
                                  ((vCount>=(car5y+8) && vCount<=(car5y+12)) &&  ((hCount==(car5x-12) || (hCount==(car5x-13))) || (hCount==(car5x-6) || (hCount==(car5x-5))) || ((hCount==(car5x+12) || (hCount==(car5x+13))) || (hCount==(car5x+6) || (hCount==(car5x+5)))))) ||
                                  ((vCount>=(car5y+12) && vCount<=(car5y+14)) && ((hCount<=(car5x-7) && hCount>=(car5x-11)) ||(hCount>=(car5x+7) && hCount<=(car5x+11))))
                                        );
										
	assign car6=( (vCount>=(car4y-4) && vCount<=(car6y+4) && hCount>=(car6x-14) && hCount<=(car6x+14))||
                                  ((vCount >=(car6y-8) && vCount <= (car6y-4)) && (((hCount>=car6x-10)&&(hCount<=car6x+2)) || ((hCount>=car6x+8) && (hCount<=car6x+10)))) ||
                                  ((vCount>=(car6y-12) && vCount<=(car6y-9)) &&  (hCount>=(car6x-10) && hCount<=(car6x+10))) ||
                                  ((vCount>=(car6y+4) && vCount<=(car6y+8)) && ((hCount>=(car6x-14) && hCount<=(car6x-12)) || (hCount>=(car6x-6) && hCount<=(car6x+6)) || (hCount>=(car6x+12) && hCount<=(car6x+14))))  || 
                                  ((vCount>=(car6y+8) && vCount<=(car6y+12)) &&  ((hCount==(car6x-12) || (hCount==(car6x-13))) || (hCount==(car6x-6) || (hCount==(car6x-5))) || ((hCount==(car6x+12) || (hCount==(car6x+13))) || (hCount==(car6x+6) || (hCount==(car6x+5)))))) ||
                                  ((vCount>=(car6y+12) && vCount<=(car6y+14)) && ((hCount<=(car6x-7) && hCount>=(car6x-11)) ||(hCount>=(car6x+7) && hCount<=(car6x+11))))
                                        );
	
	always@(posedge clk, posedge rst) 
	begin
	
		if(rst | train_hit | car1_hit | car2_hit | car3_hit | train2_hit | car4_hit | car5_hit | car6_hit | finish_hit | gameOver)
		begin
			
			/*
			if (gameOver) begin
				background <= BLACK;
			end
			*/
			
			if (rst) begin
				background <= TEAL;
				lives <= 3;
				score <= 0;
				gameOver <= 0;
				traffic_1 <= 5;
				traffic_2 <= 3;
				traffic_3 <= 4;
				traffic_4 <= 4;
			end
			
			// character position
			xpos <= 450;
			ypos <= 485;
				
			// finish line position
			finishx <= 450;
			finishy <= 80;
			finish_hit <= 0;
			
			// obstacle positions
			trainx <= 450;
			trainy <= 300;
			train_hit <= 1'b0;
			
			car1x <= 400;
			car1y <= 400;
			car1_hit <= 1'b0;
			
			car2x <= 450;
			car2y <= 400;
			car2_hit <= 1'b0;
			
			car3x <= 500;
			car3y <= 400;
			car3_hit <= 1'b0;
			
			train2x <= 450;
			train2y <= 100;
			train2_hit <= 1'b0;
			
			car4x <= 400;
			car4y <= 200;
			car4_hit <= 1'b0;
			
			car5x <= 450;
			car5y <= 200;
			car5_hit <= 1'b0;
			
			car6x <= 500;
			car6y <= 200;
			car6_hit <= 1'b0;
		end
		
		else begin
			if (!gameOver) begin
				// character
				if(right) begin
					xpos<=xpos+2;
					if(xpos==750)
						xpos<=750;
				end
				else if(left) begin
					xpos<=xpos-2;
					if(xpos==160)
						xpos<=160;
				end
				else if(up) begin
					ypos<=ypos-2;
					if(ypos==59)
						ypos<=59;
				end
				else if(down) begin
					ypos<=ypos+2;
					if(ypos==485)
						ypos<=485;
				end
			end
			
			// train 1
			if(train_hit == 1'b0) begin
				//traffic_1 <= 5;
				trainx<=trainx-traffic_1;
				if(trainx==800)
					trainx<=150;
			end
			
			if ((((xpos-trainx)<25) || ((trainx-xpos)<25)) && (((ypos-trainy)<15) || ((trainy-ypos)<15))) begin
				lives <= lives-1;
				train_hit <= 1'b1;
			end
			
			// first set of cars
			if((car1_hit == 1'b0) && (car2_hit == 1'b0) && (car2_hit == 1'b0)) begin
				car1x <= car1x+traffic_2;
				car2x <= car2x+traffic_2;
				car3x <= car3x+traffic_2;
				if(car1x==150)
					car1x<=800;
				if(car2x==150)
					car2x<=800;
				if(car3x==150)
					car3x<=800;
			end
			
			if ((((xpos-car1x)<12) || ((car1x-xpos)<12)) && (((ypos-car1y)<12) || ((car1y-ypos)<12))) begin
				lives <= lives-1;
				car1_hit <= 1'b1;
			end
			
			if ((((xpos-car2x)<12) || ((car2x-xpos)<12)) && (((ypos-car2y)<12) || ((car2y-ypos)<12))) begin
				lives <= lives-1;
				car2_hit <= 1'b1;
			end
			
			if ((((xpos-car3x)<12) || ((car3x-xpos)<12)) && (((ypos-car3y)<12) || ((car3y-ypos)<12))) begin
				lives <= lives-1;
				car3_hit <= 1'b1;
			end
			
			// train 2
			if(train2_hit == 1'b0) begin
				train2x<=train2x-traffic_3;
				if(train2x==150)
					train2x<=800;
			end
			
			if ((((xpos-train2x)<65) || ((train2x-xpos)<65)) && (((ypos-train2y)<10) || ((train2y-ypos)<10))) begin
				lives <= lives-1;
				train2_hit <= 1'b1;
			end
			
			// second set of cars
			if((car4_hit == 1'b0) && (car5_hit == 1'b0) && (car6_hit == 1'b0)) begin
				car4x <= car4x+traffic_4;
				car5x <= car5x+traffic_4;
				car6x <= car6x+traffic_4;
				if(car4x==800)
					car4x<=150;
				if(car5x==800)
					car5x<=150;
				if(car6x==800)
					car6x<=150;
			end
			
			// first set of cars
			if ((((xpos-car4x)<15) || ((car4x-xpos)<15)) && (((ypos-car4y)<13) || ((car4y-ypos)<13))) begin
				lives <= lives-1;
				car4_hit <= 1'b1;
			end
			
			if ((((xpos-car5x)<15) || ((car5x-xpos)<15)) && (((ypos-car5y)<13) || ((car5y-ypos)<13))) begin
				lives <= lives-1;
				car5_hit <= 1'b1;
			end
			
			if ((((xpos-car6x)<15) || ((car6x-xpos)<15)) && (((ypos-car6y)<13) || ((car6y-ypos)<13))) begin
				lives <= lives-1;
				car6_hit <= 1'b1;
			end
			
			// character makes it to end of map
			if ((((xpos-finishx)<505) || ((finishx-xpos)<505)) && (((ypos-finishy)<13) || ((finishy-ypos)<13))) begin
				score <= score+1;
				traffic_1 <= traffic_1+2;
				traffic_2 <= traffic_2+2;
				traffic_3 <= traffic_3+2;
				traffic_4 <= traffic_4+2;
				finish_hit <= 1'b1;
			end	
			
			// Game Over
			if (lives == 0) begin
				/*
				lives <= 3;
				score <= 0;
				*/
				gameOver <= 1;
				//background <= BLACK;
			end
		end
	end
endmodule
