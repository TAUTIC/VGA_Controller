module VGA_Memory_Controller 
(
	 clk_50, INPUT_SWS, VGA_BUS_R, VGA_BUS_G, VGA_BUS_B, VGA_HS, VGA_VS
);

input		wire				clk_50;

input		wire	[0:9]		INPUT_SWS;

output	reg	[0:3]		VGA_BUS_R;
output	reg	[0:3]		VGA_BUS_G;
output	reg	[0:3]		VGA_BUS_B;

output	reg	[0:0]		VGA_HS;
output	reg	[0:0]		VGA_VS;

			reg	[0:10]	HS_counter;
			reg	[0:9]		VS_counter;
						
			reg	[0:0]		clk_25;

initial
	begin
		VGA_BUS_R 	<= 4'b0000;
		VGA_BUS_G 	<= 4'b0000;
		VGA_BUS_B 	<= 4'b0000;
		VGA_VS		<= 1'b1;
		VGA_HS		<= 1'b1;
		
		HS_counter	<=	11'b00000000000;
		VS_counter	<= 10'b0000000000;
		
		clk_25		<= 1'b0;
	end
	
//25MHz clk for pixel
always @(posedge clk_50)
	begin
		clk_25 <= ~clk_25;
	end
	
//Timing for VGA_HS and VGA_VS
//http://tinyvga.com/vga-timing/640x480@60Hz
always @(posedge clk_50)
	begin
		case(HS_counter)
			//Wait for front porch
			11'b00000011110:				//30 pulses. Start sync.
			begin	
				VGA_HS <= 1'b0;
				HS_counter <= HS_counter + 1'b1; 
			end
			11'b00011011100:				//220 pulses. Sync over.
			begin
				VGA_HS <= 1'b1;
				HS_counter <= HS_counter + 1'b1; 
			end			
			11'b00100111011:				//315 pulses. Back porch over. Visable area begin.
			begin
				VGA_HS <= VGA_HS;
				HS_counter <= HS_counter + 1'b1; 
			end
			
			11'b11000110001:				//1585 pulses. Visable area over. Reset counter. +1 to VS_counter.
			begin
				VGA_HS <= VGA_HS;
				HS_counter <= 11'b00000000000;
				VS_counter <= VS_counter + 1'b1;
			end
			default:
			begin
				VGA_HS <= VGA_HS;
				HS_counter <= HS_counter + 1'b1; 
			end
		endcase
		
		case(VS_counter)
			//Wait for front porch
			10'b0000001010:				//10 lines. Start sync.
			begin	
				VGA_VS <= 1'b0;
			end
			10'b0000001100:				//12 lines. Sync over.
			begin
				VGA_VS <= 1'b1;
			end			
			10'b0000101101:				//45 lines. Back porch over. Visable area begin.
			begin
				VGA_VS <= VGA_VS;
			end				
			10'b1000001101:				//525 lines. Visable area over. Reset counter.
			begin
				VGA_VS <= VGA_VS;
				VS_counter <= 10'b0000000000;
			end
			default
			begin
				VGA_VS <= VGA_VS;
			end
		endcase			

	end

		
endmodule
		