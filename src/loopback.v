`include "master.v"
`include "slave.v"

module SPI_loopback#(
	parameter	
        CLK_FREQUENCY	= 50_000_000,	        // system clk frequency
		SPI_FREQUENCY	= 5_000_000,	        // spi clk frequency
		DATA_WIDTH		= 8,	                // serial word length
		CPOL			= 1,	                // SPI mode selection (mode 0 default)
		CPHA			= 1					    // CPOL = clock polarity, CPHA = clock phase
    )   
    (
	input clk,
	input rst_n,
	input [DATA_WIDTH-1:0] data_m_in,
	input [DATA_WIDTH-1:0] data_s_in,
	input start_m,

	output finish_m,
	output [DATA_WIDTH-1:0] data_m_out,
	output [DATA_WIDTH-1:0] data_s_out,
	output data_valid_s	 
    );

    wire miso;
    wire mosi;
    wire cs_n;
    wire sclk;

    spi_master 
    #(
    	.CLK_FREQUENCY (CLK_FREQUENCY ),
    	.SPI_FREQUENCY (SPI_FREQUENCY ),
    	.DATA_WIDTH    (DATA_WIDTH    ),
    	.CPOL          (CPOL          ),
    	.CPHA          (CPHA          ) 
    )
    Master(
    	.clk      (clk      ),
    	.rst_n    (rst_n    ),
    	.data_in  (data_m_in  ),
    	.start    (start_m    ),
    	.miso     (miso     ),
    	.sclk     (sclk     ),
    	.cs_n     (cs_n     ),
    	.mosi     (mosi     ),
    	.finish   (finish_m   ),
    	.data_out (data_m_out )
    );

    SPI_Slave 
    #(
    	.CLK_FREQUENCY (CLK_FREQUENCY ),
    	.SPI_FREQUENCY (SPI_FREQUENCY ),
    	.DATA_WIDTH    (DATA_WIDTH    ),
    	.CPOL          (CPOL          ),
    	.CPHA          (CPHA          ) 
    )
    Slave(
    	.clk        (clk        ),
    	.rst_n      (rst_n      ),
    	.data_in    (data_s_in    ),
    	.sclk       (sclk       ),
    	.cs_n       (cs_n       ),
    	.mosi       (mosi       ),
    	.miso       (miso       ),
    	.data_valid (data_valid_s ),
    	.data_out   (data_s_out   )
    );

endmodule