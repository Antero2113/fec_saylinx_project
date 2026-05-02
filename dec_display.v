module dec_display(
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  dec_value, // Изменено на dec_value (8 бит)
    output reg  [7:0]  seg_data,  // bit7=a_reverse, ... bit0=dp_reverse
    output reg  [7:0]  seg_sel    // ACTIVE LOW digit select
);

    // --------------------------
    // Clock divider
    // --------------------------
    reg [15:0] div;
    always @(posedge clk or posedge rst)
        if (rst) div <= 0;
        else     div <= div + 1;

    wire [2:0] digit = div[15:13]; // Будем использовать только 3 младших разряда для 3-х десятичных цифр (0-255)

    // --------------------------
    // Деление для получения десятичных цифр
    // --------------------------
    reg [3:0] digit_0; // Единицы
    reg [3:0] digit_1; // Десятки
    reg [3:0] digit_2; // Сотни

    always @(*) begin
        digit_0 = dec_value % 10;
        digit_1 = (dec_value / 10) % 10;
        digit_2 = (dec_value / 100) % 10;
    end

    // --------------------------
    // Select nibble for digit (теперь десятичная цифра)
    // --------------------------
    reg [3:0] selected_digit_value;

    always @(*) begin
        case (digit)
            3'd0: selected_digit_value = digit_0;
            3'd1: selected_digit_value = digit_1;
            3'd2: selected_digit_value = digit_2;
            default: selected_digit_value = 4'b0000; // По умолчанию, если digit > 2
        endcase
    end

    // --------------------------
    // Standard active-LOW decoder (a..g,dp)
    // --------------------------
    function [7:0] seg_encode;
        input [3:0] v;
        begin
            case (v)
                4'h0: seg_encode = 8'b11000000;
                4'h1: seg_encode = 8'b11111001;
                4'h2: seg_encode = 8'b10100100;
                4'h3: seg_encode = 8'b10110000;
                4'h4: seg_encode = 8'b10011001;
                4'h5: seg_encode = 8'b10010010;
                4'h6: seg_encode = 8'b10000010;
                4'h7: seg_encode = 8'b11111000;
                4'h8: seg_encode = 8'b10000000;
                4'h9: seg_encode = 8'b10010000;
                default: seg_encode = 8'b11111111; // Все сегменты выключены для несуществующих цифр
            endcase
        end
    endfunction

    // --------------------------
    // Bit reverse dp,g,f,e,d,c,b,a  → a,b,c,d,e,f,g,dp
    // --------------------------
    function [7:0] reverse_bits;
        input [7:0] x;
        begin
            reverse_bits = {
                x[0],  // dp -> MSB
                x[1],  // g
                x[2],  // f
                x[3],  // e
                x[4],  // d
                x[5],  // c
                x[6],  // b
                x[7]   // a -> LSB
            };
        end
    endfunction

    // --------------------------
    // Apply encoding + reverse
    // --------------------------
    always @(*) begin
        seg_data = reverse_bits(seg_encode(selected_digit_value));
    end

    // --------------------------
    // Digit select (ACTIVE LOW)
    // --------------------------
    always @(*) begin
        seg_sel = 8'b11111111;   // all OFF
        seg_sel[digit] = 1'b0;   // enable this digit
    end

endmodule