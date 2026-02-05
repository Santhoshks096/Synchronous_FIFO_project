`include "synch_fifo.v"
`define PRINT 1
module top;
//declaring parameter
	parameter DEPTH=16;
	parameter DATA_WIDTH=12;
	parameter PTR_WIDTH=$clog2(DEPTH);

//declaring reg &output ports
	reg clk_i,rst_i,wr_en_i,rd_en_i;
	reg [DATA_WIDTH-1:0]wdata_i;
	wire[DATA_WIDTH-1:0]rdata_o;
	wire full_o,overflow_o,empty_o,underflow_o;

	integer i;
	reg[35*8:0] testname;

	synch #(.DEPTH(DEPTH),.DATA_WIDTH(DATA_WIDTH))dut(.clk_i				(clk_i),
				                                     	.rst_i				(rst_i),
                                                      	.wr_en_i			(wr_en_i),
                                                     	.wdata_i			(wdata_i),
                                                    	.full_o				(full_o),
                                                     	.overflow_o			(overflow_o),
  														.rd_en_i			(rd_en_i),
														.rdata_o			(rdata_o),
														.empty_o			(empty_o),
					                                    .underflow_o		(underflow_o));

// clock generation
	initial begin
		clk_i=0;
		forever #5 clk_i=~clk_i;
	end

	initial begin
		reset_fifo();
		$value$plusargs("testcase=%s",testname);
		$display("\t-->passing test=%0s",testname);
		case(testname)
			"test_1wr":begin
		   	write_fifo(0,1);
		end
			"test_5wr":begin
			write_fifo(0,5);
		end
			"test_nwr":begin
			write_fifo(0,DEPTH);
		end	
			"test_nwr_nrd":begin
			write_fifo(0,DEPTH);
			read_fifo(0,DEPTH);
		end
			"test_1wr_1rd":begin
			write_fifo(0,1);
			read_fifo(0,1);
		end	
			"test_5wr_5rd":begin
			write_fifo(0,5);
			read_fifo(0,5);
		end	
			"test_1wr_1rd":begin
			write_fifo(0,1);
			read_fifo(0,1);
		end	
			"test_full":begin
			write_fifo(0,DEPTH);
		end	
			"test_overflow":begin
			write_fifo(0,DEPTH+5);
		end	
			"test_empty":begin
			read_fifo(0,DEPTH);
		end	
			"test_underflow":begin
			write_fifo(0,DEPTH);
			read_fifo(0,DEPTH+4);
		end	
			"test_over_underflow":begin
			write_fifo(0,DEPTH+6);
			read_fifo(0,DEPTH+4);
		   	print_state();
		end			
	endcase
	     	#100;
			$finish();
	end
		task print_state();
			begin
				@(posedge clk_i);
			if(full_o==1) $display("\t-->%0t FIFO wires reach to the DEPTH size indicates full",$time);
			if(empty_o==1) $display("\t-->%0t FIFO wires reach to the DEPTH size indicates empty",$time);
			if(overflow_o==1) $display("\t-->%0t FIFO wires reach to the DEPTH size writing the data into the FIFO indicates overflow",$time);
			if(underflow_o==1) $display("\t-->%0t FIFO wires reach to the DEPTH size writing the data into the FIFO indicates overflow",$time);
			end
	endtask

//reset clock
	task reset_fifo();
		begin
			rst_i=1;
			wr_en_i=0;
			rd_en_i=0;
			wdata_i=0;
			repeat(2)@(posedge clk_i);
			rst_i=0;
		end
	endtask
// write_fifo
	task write_fifo(input integer start_loc,end_loc);
		begin
			if(`PRINT==1)$display("-----------write fifo-------------");
			for(i=start_loc;i<end_loc;i=i+1)begin
				@(posedge clk_i);
				wr_en_i=1;
				wdata_i=$random;
			   if(`PRINT==1)$display("\t-->wr_pointer=%0d||wdata=%0h",dut.wr_ptr,wdata_i);
			end
				@(posedge clk_i);
				wr_en_i=0;
				wdata_i=0;
			end
	endtask

// read_fifo
	task read_fifo(input integer start_loc,end_loc);
		begin
			if(`PRINT==1)$display("-----------read fifo-------------");
			for(i=start_loc;i<end_loc;i=i+1)begin
				@(posedge clk_i);
				rd_en_i=1;
				if(`PRINT==1)$display("\t--> rd_pointer=%0d||rdata=%0h",dut.rd_ptr,rdata_o);
			end
				@(posedge clk_i);
				rd_en_i=0;
			end
	endtask
endmodule
