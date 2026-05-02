`timescale 1ns / 1ps

module tb_fec_saylinx_board_top_modelsim;

    reg CLK;
    reg RST_N;
    reg KEY2_N;
    reg KEY3_N;
    reg KEY4_N;
    wire [3:0] LED;
    wire [7:0] SEG_DATA;
    wire [7:0] SEG_SEL;
    wire [16:0] GPIO_0_out_zero_value;
    reg  [16:0] GPIO_0_input_pullup;
    wire [16:0] GPIO_1_out_zero_value;
    reg  [16:0] GPIO_1_input_pullup;
    
    fec_saylinx_board_top dut (
        .CLK(CLK),
        .RST_N(RST_N),
        .KEY2_N(KEY2_N),
        .KEY3_N(KEY3_N),
        .KEY4_N(KEY4_N),
        .LED(LED),
        .SEG_DATA(SEG_DATA),
        .SEG_SEL(SEG_SEL),
        .GPIO_0_out_zero_value(GPIO_0_out_zero_value),
        .GPIO_0_input_pullup(GPIO_0_input_pullup),
        .GPIO_1_out_zero_value(GPIO_1_out_zero_value),
        .GPIO_1_input_pullup(GPIO_1_input_pullup)
    );
    
    initial begin
        CLK = 1'b0;
        forever #5 CLK = ~CLK;
    end
    
    integer test_num;
    integer a_val, b_val;
    integer expected_result;
    integer actual_result;
    integer passed_tests;
    integer failed_tests;
    
    initial begin
        passed_tests = 0;
        failed_tests = 0;
        
        RST_N = 1'b0;
        KEY2_N = 1'b1;
        KEY3_N = 1'b1;
        KEY4_N = 1'b1;
        GPIO_0_input_pullup = 17'h1FFFF;
        GPIO_1_input_pullup = 17'h1FFFF;
        
        $display("========================================");
        $display("ModelSim Test for fec_saylinx_board_top");
        $display("Formula: y = sqrt(a + cbrt(b))");
        $display("========================================");
        $display("");
        
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        RST_N = 1'b1;
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        @(posedge CLK);
        
        $display("Test table:");
        $display("%-6s | %-6s | %-6s | %-10s | %-10s | %-6s", 
                 "Test", "a", "b", "Expected", "Got", "Result");
        $display("------------------------------------------------------------");
        
        test_num = 1;
        a_val = 10;
        b_val = 27;
        expected_result = 3;
        run_test(test_num, a_val, b_val, expected_result);
        
        test_num = 2;
        a_val = 20;
        b_val = 64;
        expected_result = 4;
        run_test(test_num, a_val, b_val, expected_result);
        
        test_num = 3;
        a_val = 5;
        b_val = 8;
        expected_result = 2;
        run_test(test_num, a_val, b_val, expected_result);
        
        test_num = 4;
        a_val = 16;
        b_val = 8;
        expected_result = 4;
        run_test(test_num, a_val, b_val, expected_result);
        
        test_num = 5;
        a_val = 25;
        b_val = 27;
        expected_result = 5;
        run_test(test_num, a_val, b_val, expected_result);
        
        test_num = 6;
        a_val = 0;
        b_val = 0;
        expected_result = 0;
        run_test(test_num, a_val, b_val, expected_result);
        
        test_num = 7;
        a_val = 1;
        b_val = 1;
        expected_result = 1;
        run_test(test_num, a_val, b_val, expected_result);
        
        $display("------------------------------------------------------------");
        $display("");
        $display("Summary: PASSED = %d, FAILED = %d", passed_tests, failed_tests);
        $display("");
        
        if (failed_tests == 0) begin
            $display("========================================");
            $display("ALL TESTS PASSED!");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("SOME TESTS FAILED!");
            $display("========================================");
        end
        
        #1000;
        $stop;
    end
    
    task run_test;
        input integer test_id;
        input integer a;
        input integer b;
        input integer expected;
        
        integer result;
        reg done_flag;
        integer i;
        integer wait_count;
        begin
            GPIO_0_input_pullup[15:8] = ~a[7:0];
            GPIO_0_input_pullup[7:0] = ~b[7:0];
            
            KEY3_N = 1'b0;
            @(posedge CLK);
            @(posedge CLK);
            KEY3_N = 1'b1;
            @(posedge CLK);
            @(posedge CLK);
            
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
            
            if (dut.mode != 1'b0) begin
                $display("Warning: Not in MODE_INPUT before test %d", test_id);
            end
            
            KEY2_N = 1'b0;
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
            
            KEY2_N = 1'b1;
            @(posedge CLK);
            @(posedge CLK);
            
            @(posedge CLK);
            @(posedge CLK);
            if (dut.mode != 1'b1) begin
                $display("Warning: Not in MODE_RUN after START in test %d", test_id);
            end
            
            done_flag = 1'b0;
            result = 0;
            
            for (i = 0; i < 50000; i = i + 1) begin
                @(posedge CLK);
                
                if (dut.done_formula == 1'b1) begin
                    result = dut.y_out[7:0];
                    done_flag = 1'b1;
                    i = 50000;
                end
            end
            
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
            
            if (!done_flag) begin
                result = dut.y_out[7:0];
            end
            
            actual_result = result;
            
            if (done_flag) begin
                if ((result == expected) || (result == expected + 1) || (result == expected - 1)) begin
                    $display("%-6d | %-6d | %-6d | %-10d | %-10d | PASS", 
                             test_id, a, b, expected, result);
                    passed_tests = passed_tests + 1;
                end else begin
                    $display("%-6d | %-6d | %-6d | %-10d | %-10d | FAIL", 
                             test_id, a, b, expected, result);
                    $display("  Error: expected %d, got %d", expected, result);
                    failed_tests = failed_tests + 1;
                end
            end else begin
                $display("%-6d | %-6d | %-6d | %-10d | %-10d | FAIL (timeout)", 
                         test_id, a, b, expected, result);
                $display("  Error: computation timeout (done signal not set)");
                failed_tests = failed_tests + 1;
            end
            
            KEY3_N = 1'b0;
            @(posedge CLK);
            @(posedge CLK);
            KEY3_N = 1'b1;
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
        end
    endtask

endmodule
