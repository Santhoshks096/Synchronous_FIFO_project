// implement the synchoronous fifo
`timescale 1ns/1ps
module synch(
	clk_i,rst_i,
	wr_en_i,wdata_i,full_o,overflow_o,
	rd_en_i,rdata_o,empty_o,underflow_o);

//declaring the parameter
	parameter DEPTH=16;
	parameter DATA_WIDTH=12;
	parameter PTR_WIDTH=$clog2(DEPTH);

// Declaring the input and output ports
	input clk_i,rst_i,wr_en_i,rd_en_i;
	input [DATA_WIDTH-1:0]wdata_i;
	output reg [DATA_WIDTH-1:0]rdata_o;
	output reg full_o,overflow_o,empty_o,underflow_o;

//declaring the memory
	reg[DATA_WIDTH-1:0]fifo[DEPTH-1:0];

//internal signal 
	reg[PTR_WIDTH-1:0]wr_ptr,rd_ptr;
	reg wr_toggle_f,rd_toggle_f;
	integer i;

// fifo functionality
	always@(posedge clk_i)begin
			if(rst_i==1)begin
			rdata_o=0;
			full_o=0;
			empty_o=1;
			overflow_o=0;
			underflow_o=0;
			wr_ptr=0;
			rd_ptr=0;
			wr_toggle_f=0;
			rd_toggle_f=0;
			for(i=0;i<DEPTH;i=i+1)begin
				fifo[i]=0;
			end		
		end
// write_fifo logic
		else begin
			overflow_o=0;
			underflow_o=0;
			if(wr_en_i==1)begin
				if(full_o==1)begin
					overflow_o=1;
				end
				else begin
					fifo[wr_ptr]=wdata_i;
					if(wr_ptr==DEPTH-1)begin
						wr_toggle_f=~wr_toggle_f;
					end
					wr_ptr=wr_ptr+1;
				end
			end
// read_fifo logic
			if(rd_en_i==1)begin
				if(empty_o==1)begin
					underflow_o=1;
				end
				else begin
					rdata_o=fifo[rd_ptr];
					if(rd_ptr==DEPTH-1)begin
						rd_toggle_f=~rd_toggle_f;
					end
					rd_ptr=rd_ptr+1;
				end
			end  
		end
	end
// full & empty condition
	always@(*)begin
			full_o=0;
			empty_o=0;
		if(wr_ptr==rd_ptr && wr_toggle_f!=rd_toggle_f)begin
			full_o=1;
		end
		if(wr_ptr==rd_ptr && wr_toggle_f==rd_toggle_f)begin
			empty_o=1;
		end
	end
endmodule
