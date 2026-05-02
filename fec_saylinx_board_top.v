`timescale 1ns/1ps

module fec_saylinx_board_top
(
    input           CLK,
    input           RST_N,
    input           KEY2_N,
    input           KEY3_N,
    input           KEY4_N,
    output [3:0]    LED,
    output [7:0]    SEG_DATA,
    output [7:0]    SEG_SEL,
    output [16:0]   GPIO_0_out_zero_value,
    input  [16:0]   GPIO_0_input_pullup,
    output [16:0]   GPIO_1_out_zero_value,
    input  [16:0]   GPIO_1_input_pullup
);

    wire clk = CLK;
    wire rst = ~RST_N;

    assign GPIO_0_out_zero_value = 17'b0;
    assign GPIO_1_out_zero_value = 17'b0;

    wire start_btn = ~KEY2_N;
    wire reset_btn = ~KEY3_N;
   
    // Чтение входных данных A и B из GPIO
    wire [7:0] A_in = ~GPIO_0_input_pullup[15:8];
    wire [7:0] B_in = ~GPIO_0_input_pullup[7:0];

    reg [7:0] A_reg, B_reg;
   
    wire done_formula;
    wire [23:0] y_out;
   
    // Преобразование операндов в BCD для отображения
    wire [3:0] A_hund, A_tens, A_ones;

    bin_to_bcd_4digit u_bcd(
        .bin(A_reg),
        .hund(A_hund),
        .tens(A_tens),
        .ones(A_ones)
    );
  
    wire [3:0] B_hund, B_tens, B_ones;

    bin_to_bcd_4digit u_bcd_b(
        .bin(B_reg),
        .hund(B_hund),
        .tens(B_tens),
        .ones(B_ones)
    );

    // Преобразование результата в BCD
    wire [3:0] R_thous, R_hund, R_tens, R_ones;

    bin_to_bcd_4digit u_bcd_res4(
        .bin(y_out[11:0]),
        .thous(R_thous),
        .hund(R_hund),
        .tens(R_tens),
        .ones(R_ones)
    );

    // Конечный автомат для управления режимами работы
    localparam MODE_INPUT = 1'b0;
    localparam MODE_RUN   = 1'b1;

    reg mode;

    reg start_latch;
    always @(posedge clk or posedge rst)
        if (rst) start_latch <= 0;
        else     start_latch <= start_btn;

    // Модуль вычисления формулы
    formula #(.N(8)) u_formula (
        .clk(clk),
        .rst(rst),
        .enable(start_latch),
        .a(A_reg),
        .b(B_reg),
        .y(y_out),
        .done(done_formula)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mode <= MODE_INPUT;
        end else begin
            case (mode)
                MODE_INPUT: begin
                    A_reg <= A_in;
                    B_reg <= B_in;
                    if (start_btn) mode <= MODE_RUN;
                end

                MODE_RUN: begin
                    if (reset_btn) mode <= MODE_INPUT;
                end
            endcase
        end
    end

    // Вывод на светодиоды
    assign LED[0]   = (mode == MODE_RUN) ? done_formula : 1'b0;
    assign LED[3:1] = y_out[2:0];

    // Формирование данных для семисегментного дисплея
    reg [31:0] disp_val;

    always @(*) begin
        disp_val = 32'h00000000;

        if (mode == MODE_INPUT) begin
            disp_val[31:28] = 4'h0;
            disp_val[27:24] = A_hund;
            disp_val[23:20] = A_tens;
            disp_val[19:16] = A_ones;
            disp_val[15:12] = 4'h0;
            disp_val[11: 8] = B_hund;
            disp_val[ 7: 4] = B_tens;
            disp_val[ 3: 0] = B_ones;
        end
        else begin
            disp_val[31:16] = 16'h0000;
            disp_val[15:12] = R_thous;
            disp_val[11: 8] = R_hund;
            disp_val[ 7: 4] = R_tens;
            disp_val[ 3: 0] = R_ones;
        end
    end

    hex_display u_hex (
        .clk(clk),
        .rst(rst),
        .hex_value(disp_val),
        .seg_data(SEG_DATA),
        .seg_sel(SEG_SEL)
    );

endmodule
