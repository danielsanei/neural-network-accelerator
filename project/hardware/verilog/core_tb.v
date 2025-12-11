// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;

reg clk = 0;
reg reset = 1;

wire [35:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN_xmem = 1;
reg WEN_xmem = 1;
reg [10:0] A_xmem = 0;
reg CEN_xmem_q = 1;
reg WEN_xmem_q = 1;
reg [10:0] A_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg [1:0] sfu_mode_q = 0;
reg [1:0] sfu_mode = 0;
reg sfu_in_select_q = 0;
reg sfu_in_select = 0;

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] acc_out;
reg [psum_bw*col-1:0] answer;


reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij;
integer error;

// pmem stuff
integer H = $floor($sqrt(len_nij));
integer K = $floor($sqrt(len_kij));
integer OUT_H = $floor($sqrt(len_onij));

integer out_idx;
integer k_idx;
integer out_row, out_col;
integer k_row, k_col;
integer base_addr, offset;

assign inst_q[35] = sfu_in_select_q;
assign inst_q[34:33] = sfu_mode_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 


core  #(.bw(bw), .col(col), .row(row)) core_instance (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid),
        .D_xmem(D_xmem_q), 
        .sfp_out(sfp_out), 
	.reset(reset)); 


initial begin 

  inst_w   = 0; 
  D_xmem   = 0;
  CEN_xmem = 1;
  WEN_xmem = 1;
  A_xmem   = 0;
  ofifo_rd = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  execute  = 0;
  load     = 0;

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  x_file = $fopen("activation_tile0.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t=0; t<len_nij; t=t+1) begin  
    #0.5 clk = 1'b0;  x_scan_file = $fscanf(x_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
  /////////////////////////////////////////////////


  for (kij=0; kij<9; kij=kij+1) begin  // kij loop

    case(kij)
     0: w_file_name = "weight_itile0_otile0_kij0.txt";
     1: w_file_name = "weight_itile0_otile0_kij1.txt";
     2: w_file_name = "weight_itile0_otile0_kij2.txt";
     3: w_file_name = "weight_itile0_otile0_kij3.txt";
     4: w_file_name = "weight_itile0_otile0_kij4.txt";
     5: w_file_name = "weight_itile0_otile0_kij5.txt";
     6: w_file_name = "weight_itile0_otile0_kij6.txt";
     7: w_file_name = "weight_itile0_otile0_kij7.txt";
     8: w_file_name = "weight_itile0_otile0_kij8.txt";
    endcase
    

    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

    #0.5 clk = 1'b0;   reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   





    /////// Kernel data writing to memory ///////

    A_xmem = 11'b10000000000;

    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1; 
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////

  // SRAM to L0
  // SRAM data => L0 in
  // |   |   |      |
// A_x CEN  WEN    l0_wr
 
    /////// Kernel data writing to L0 ///////
    // prime SRAM and delay by a cycle, wr first addr to sram
    #0.5 clk = 1'b0;
    CEN_xmem = 0; // turn on SRAM
    WEN_xmem = 1; // read out mode
    A_xmem = 11'b10000000000;
    l0_wr = 0;
    #0.5 clk = 1'b1; 

    for (t=0; t<col; t=t+1) begin
      #0.5 clk = 1'b0;
      // Capture data from prev cycle req -> SRAM has 1 cycle delay
      l0_wr = 1;
      // prep addrs
      if (t<col-1) begin
        A_xmem = A_xmem + 1;
      end 

      #0.5 clk = 1'b1;
    end

    // // iteration v3
    // // load in 0x407
    // #0.5 clk = 1'b0;
    // l0_wr = 1;
    // CEN_xmem = 1; // turn off SRAM but get its last output
    // #0.5 clk = 1'b1;

    // full l0 off
    #0.5 clk = 1'b0;
    CEN_xmem = 1;
    l0_wr = 0;
    #0.5 clk = 1'b1;

    // itervation v2
    // // turn off L0
    // #0.5 clk = 1'b0;
    // l0_wr = 0;
    // CEN_xmem = 1;
    // WEN_xmem = 1;
    // #0.5 clk = 1'b1;

  //   for (t=0; t<col; t=t+1) begin
  //   	#0.5 clk = 1'b0 CEN_xmem = 0; WEN_xmem = 1; A_xmem = 11'b10000000000 + t[10:0]; l0_wr = 1;
	// #0.5 clk = 1'b1;
  //   end

  //   #0.5 clk = 1'b0; l0_wr = 0; CEN_xmem = 1; WEN_xmem = 1;
  //   #0.5 clk = 1'b1;
    /////////////////////////////////////



    /////// Kernel loading to PEs ///////
    // 4bits change at a time with l0
    // skew shift in row+col len_kij loop for skewed inputs
    for (t=0; t<col+row; t=t+1) begin
      #0.5 clk = 1'b0; load = 1; l0_rd = 1;
      #0.5 clk = 1'b1;
    end

    #0.5 clk = 1'b0; load = 0; l0_rd = 0;
    #0.5 clk = 1'b1;
    /////////////////////////////////////
  


    ////// provide some intermission to clear up the kernel loading ///
    #0.5 clk = 1'b0;  load = 0; l0_rd = 0;
    #0.5 clk = 1'b1;  
  

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////



    /////// Activation data writing to L0 ///////
    // turn on SRAM and establish first first sram addr to send to l0
    #0.5 clk = 1'b0;
    CEN_xmem = 0;
    WEN_xmem = 1;
    A_xmem = 11'b00000000000;
    l0_wr = 0;
    #0.5 clk = 1'b1;

    // loop addrs sent to l0
    for (t=0; t < len_nij; t=t+1) begin
      #0.5 clk = 1'b0;
      // establish l0
      l0_wr = 1;
      // next addr
      if (t < len_nij - 1) begin
        A_xmem = A_xmem + 1;
      end else begin
        CEN_xmem = 1;
      end
      #0.5 clk = 1'b1;
    end

    // turn off SRAM
    #0.5 clk = 1'b0;
    l0_wr = 0;
    CEN_xmem = 1;
    WEN_xmem = 1;
    #0.5 clk = 1'b1;

  //   for (t=0; t<len_nij; t=t+1) begin
  //   	#0.5 clk = 1'b0; CEN_xmem = 0; WEN_xmem = 1; l0_wr = 1;
	// #0.5 clk = 1'b1; A_xmem = A_xmem + 1;
  //   end

  //   #0.5 clk = 1'b0; l0_wr = 0; CEN_xmem = 1; WEN_xmem = 1;
  //   #0.5 clk = 1'b1;
    /////////////////////////////////////

  // #0.5 clk = 1'b0;
  // l0_rd = 1;
  // execute = 0;
  // #0.5 clk = 1'b1;

    /////// Execution /////// ~36 cycles
    for (t=0; t<row+col+(len_nij-col); t=t+1) begin // stream inputs in (pipeline) + row+col (prop across array)
    	#0.5 clk = 1'b0; execute = 1; l0_rd = 1;
	#0.5 clk = 1'b1;
    end

    #0.5 clk = 1'b0; execute = 0; l0_rd = 0;
    #0.5 clk = 1'b1;
    /////////////////////////////////////
    // per kij
    // nij=16 out_s values generated -> psum memory

    // PSUM MEMORY CONTENTS
    // kij=1
      //   nij=0
      //   nij=1
      //   nij=2
      //   ...
      //   nij=9
    // kij=2
      //   nij=0
      //   nij=1
      //   nij=2
      //   ...
      //   nij=9
    // kij=3
      //   nij=0
      //   nij=1
      //   nij=2
      //   ...
      //   nij=9
    // kij=4
      //   nij=0
      //   nij=1
      //   nij=2
      //   ...
      //   nij=9
    // kij=5
      //   nij=0
      //   nij=1
      //   nij=2
      //   ...
      //   nij=9
    // kij=6
      //   nij=0
      //   nij=1
      //   nij=2
      //   ...
      //   nij=9
    // kij=7
      //   nij=0
      //   nij=1
      //   nij=2
      //   ...
      //   nij=9
    // kij=8
      //   nij=0
      //   nij=1
      //   nij=2
      //   ...
      //   nij=9
    // kij=9
      //   nij=0
      //   nij=1
      //   nij=2
      //   ...
      //   nij=9

  //   ////// OFIFO READ ////////
  //   Ideally, OFIFO should be read while execution, but we have enough ofifo
  //   depth so we can fetch out after execution.
  // read out to and accum in sfu 16 times
    // wait 1 clk cycle for valid out and 1 cycle earlier to prime pmem
    // enable pmem and slurp values through sfu
    #0.5 clk = 1'b0;
    A_pmem = kij*len_nij-1; // use kij as base for address that pmem will use for storage, 9 kij rows by 36 potential psum slots (16 of them are real)
    sfu_mode = 2'b00; // pass through
    WEN_pmem = 1;
    CEN_pmem = 1;
    ofifo_rd = 1; // 1222c
    #0.5 clk = 1'b1;
    t=0;
    // 1 cycle delay for sfu pass through
    #0.5 clk = 1'b0; #0.5 clk = 1'b1;
    while (t < len_nij) begin
      #0.5 clk = 1'b0; 
      if (ofifo_valid) begin
        ofifo_rd = 1; sfu_mode = 2'b00;

        //$display("[DEBUG] Time: %0t | t=%0d | Raw OFIFO Data: %h", $time, t, core_instance.corelet_inst.ofifo_out);
        // pmem slurp up sfu pass through values for accum later
        CEN_pmem = 0;
        WEN_pmem = 0;
        A_pmem = A_pmem + 1;
        t = t + 1;
      end
      else begin
        ofifo_rd = 0;
        sfu_mode = 2'b00;
      end
      #0.5 clk = 1'b1;
    end

    #0.5 clk = 1'b0; ofifo_rd = 0; sfu_mode = 2'b00; CEN_pmem=1; WEN_pmem=1; #0.5 clk = 1'b1;
    #0.5 clk=1'b0; #0.5 clk = 1'b1;
    #0.5 clk=1'b0; #0.5 clk = 1'b1;

    // debug read out of pmem for 36 values
    // A_pmem = kij * len_nij - 1;
    // for (i = 0; i < len_nij; i = i + 1) begin
    //   #0.5 clk = 1'b0;
    //   CEN_pmem = 0;
    //   WEN_pmem = 1;
    //   A_pmem = A_pmem + 1;
    //   #0.5 clk = 1'b1;
    // end
    // // 2 cycle delay for read out
    // // #0.5 clk = 1'b0; CEN_pmem = 0; WEN_pmem = 1; #0.5 clk = 1'b1;
    // #0.5 clk = 1'b0; CEN_pmem = 0; WEN_pmem = 1; #0.5 clk = 1'b1;
    // #0.5 clk = 1'b0; CEN_pmem = 1; WEN_pmem = 1; #0.5 clk = 1'b1;


    
    /////////////////////////////////////
  end  // end of kij loop


  ////////// Accumulation /////////
  out_file = $fopen("out.txt", "r");  

  acc_file = $fopen("acc.txt", "w");


  // Following three lines are to remove the first three comment lines of the file
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;


  // drive ofifo, sfu, alongside answer checking to not lose data
  $display("############ Verification Start during accumulation #############"); 

  // 1. Read 36 values from pmem, choose which are 16 needed to calculate final solution from ea
  // 2. Send to SFU to accumulate
  // 3. Store in pmem
  // 4. Read out from pmem and check against known answer

  sfu_in_select = 1; // send pmem stuff to sfu
  sfu_mode = 2'b01; // accumulate mode in sfu
  for (out_idx=0; out_idx<len_onij; out_idx=out_idx+1) begin 
    // write output value to text file acc.txt to chcek
    $fdisplay(acc_file, "%b", sfp_out);
    // assert read accumulate
    for (k_idx = 0; k_idx < len_kij; k_idx = k_idx + 1) begin
      // read out pmem values
      #0.5 clk = 1'b0; 
      sfu_mode =  2'b01;
      CEN_pmem = 0; 
      WEN_pmem = 1; 
      // base addr + offset
      out_row = out_idx / OUT_H;
      out_col = out_idx % OUT_H;
      k_row = k_idx / K;
      k_col = k_idx % K;
      base_addr = k_idx*len_nij;
      offset = ((out_row + k_row)*H+(out_col+k_col));
      A_pmem = base_addr + offset;
      // $display("nij idx: %d", offset);
      #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0; CEN_pmem=1; sfu_mode =  2'b10; #0.5 clk = 1'b1; // cycle delay for accum + rd out for sfu
  end
  // two clock after delay for read out
  $fdisplay(acc_file, "%b", sfp_out);
  #0.5 clk = 1'b0; #0.5 clk = 1'b1;
  $fdisplay(acc_file, "%b", sfp_out);
  #0.5 clk = 1'b0; #0.5 clk = 1'b1;
  $fdisplay(acc_file, "%b", sfp_out);


  $fclose(acc_file);
  acc_file = $fopen("acc.txt", "r");


  // Following three lines are to remove the first three comment lines of the file
  acc_scan_file = $fscanf(acc_file,"%s", acc_out); 
  acc_scan_file = $fscanf(acc_file,"%s", acc_out); 
  acc_scan_file = $fscanf(acc_file,"%s", acc_out); 

  for (i = 0; i < len_onij; i = i + 1) begin
    out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
    acc_scan_file = $fscanf(acc_file,"%128b", acc_out); 
    if (acc_out == answer)
      $display("%2d-th output featuremap Data matched! :D", i); 
    else begin
      $display("%2d-th output featuremap Data ERROR!!", i); 
      $display("acc_out: %128b", acc_out);
      $display("answer: %128b", answer);
      $display("acc_out: %d", acc_out);
      $display("answer: %d", answer);
      error = 1;
    end
  end


  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  $fclose(acc_file);
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  #10 $finish;

end

always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   sfu_in_select_q <= sfu_in_select;
   sfu_mode_q      <= sfu_mode;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
end





endmodule




