module bin_to_bcd_4digit(
    input  [11:0] bin,
    output [3:0] thous,
    output [3:0] hund,
    output [3:0] tens,
    output [3:0] ones
);
    assign thous = bin / 1000;
    assign hund  = (bin % 1000) / 100;
    assign tens  = (bin % 100) / 10;
    assign ones  = bin % 10;
endmodule
