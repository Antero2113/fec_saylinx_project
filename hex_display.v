module hex_display(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] hex_value,
    output reg  [7:0]  seg_data = 8'b11111111,
    output reg  [7:0]  seg_sel  = 8'b11111111
);

    reg [15:0] div = 16'b0;
    always @(posedge clk or posedge rst)
        if (rst) div <= 0;
        else     div <= div + 1;

    wire [2:0] digit = div[15:13];

    reg [3:0] nibble = 4'b0;

    always @(*) begin
        case (digit)
            3'd0: nibble = hex_value[ 3: 0];
            3'd1: nibble = hex_value[ 7: 4];
            3'd2: nibble = hex_value[11: 8];
            3'd3: nibble = hex_value[15:12];
            3'd4: nibble = hex_value[19:16];
            3'd5: nibble = hex_value[23:20];
            3'd6: nibble = hex_value[27:24];
            3'd7: nibble = hex_value[31:28];
            default: nibble = 4'b0;
        endcase
    end

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
                4'hA: seg_encode = 8'b10001000;
                4'hB: seg_encode = 8'b10000011;
                4'hC: seg_encode = 8'b11000110;
                4'hD: seg_encode = 8'b10100001;
                4'hE: seg_encode = 8'b10000110;
                4'hF: seg_encode = 8'b10001110;
                default: seg_encode = 8'b11111111;
            endcase
        end
    endfunction

    function [7:0] reverse_bits;
        input [7:0] x;
        begin
            reverse_bits = {
                x[0],
                x[1],
                x[2],
                x[3],
                x[4],
                x[5],
                x[6],
                x[7]
            };
        end
    endfunction

    always @(*) begin
        seg_data = reverse_bits(seg_encode(nibble));
    end

    always @(*) begin
        seg_sel = 8'b11111111;
        if (digit < 8) begin
            seg_sel[digit] = 1'b0;
        end
    end

endmodule
