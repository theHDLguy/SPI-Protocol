`include "master.v"
`include "slave.v"

module SPI_Master_tb();

	parameter	
        CLK_FREQUENCY	= 50_000_000,	        // system clk frequency
		SPI_FREQUENCY	= 5_000_000,	        // spi clk frequency
		DATA_WIDTH		= 8,	                // serial word length
		CPOL			= 1,	                // SPI mode selection (mode 0 default)
		CPHA			= 1;					// CPOL = clock polarity, CPHA = clock phase

	reg	clk;
	reg	rst_n;
	reg	[DATA_WIDTH-1:0] data_in;
	reg	start;
	reg	miso;

	wire sclk;
	wire cs_n;
	wire mosi;
	wire finish;
	wire [DATA_WIDTH-1:0] data_out;


	//DUT
	spi_master #(
		.CLK_FREQUENCY (CLK_FREQUENCY ),
		.SPI_FREQUENCY (SPI_FREQUENCY ),
		.DATA_WIDTH    (DATA_WIDTH    ),
		.CPOL          (CPOL          ),
		.CPHA          (CPHA          )
	)
	u_spi_master(
		.clk         (clk         ),
		.rst_n       (rst_n       ),
		.data_in     (data_in     ),
		.start       (start       ),
		.miso        (miso        ),
		.sclk        (sclk        ),
		.cs_n        (cs_n        ),
		.mosi        (mosi        ),
		.finish 	 (finish	  ),
		.data_out    (data_out    )
	);

	//the clk generation
	initial begin
		clk = 1;
		forever #10 clk = ~clk;
	end


	//the rst_n generation
	initial begin
		rst_n = 1'b0;
		#22 rst_n = 1'b1;
	end


	//the main block
	initial fork
		data_in_generate;
		start_change;
		debug_information;
	join


	//to generate data_in
	task data_in_generate;
	begin
		data_in = 'd0;
		@(posedge rst_n)
		data_in <= 8'b10100101;
		@(posedge finish)
		data_in <= 8'b10011010;
		@(negedge finish)
		@(negedge finish)
		#20 $finish;
	end
	endtask


	//to generate the start signal
	task start_change;
	begin
		start = 1'b0;
		@(posedge rst_n)
		#20 start <= 1'b1;
		#20 start = 1'b0;
		@(negedge finish)
		#20 start = 1'b1;
		#20 start = 1'b0;
	end
	endtask


	//to display the debug information
	task debug_information;
	begin
	     $display("---------------------------------------------------");  
	     $display("------------------------   ------------------------");  
	     $display("---------------- SIMULATION RESULT ----------------"); 
	     $display("------------------------   ------------------------");   
	     $display("---------------------------------------------------");  

	     $monitor("TIME = %d | mosi = %b | miso = %b | data_in = %b",$time, mosi, miso, data_in);  
	end
	endtask


	//the generate block to generate the miso
	generate
		if(CPHA == 0)
			always @(negedge sclk)
				miso = $random;

		else
			always @(posedge sclk)
				miso = $random;
	endgenerate


	//to generate uart_frame_tx_tb.vcd
	initial begin
		$dumpfile("SPI_Master_tb.vcd");
		$dumpvars();
	end

endmodule