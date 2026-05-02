module cbrt #(
    parameter N = 8
) (
    input  wire           clk,
    input  wire           rst,
    input  wire           enable,
    input  wire [N-1:0]   x,
    output reg  [N-1:0]   y,
    output reg            done,
    output reg            busy
);

    localparam IDLE       = 2'b00;
    localparam WORK       = 2'b01;
    localparam DONE_STATE = 2'b10;

    reg [1:0] state;
    
    reg [2*N-1:0] x_reg;
    reg [N+7:0]   y_reg;
    reg [7:0]     shift;
    reg [3*N+7:0] b;
    reg [N+7:0]   y_shift;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state  <= IDLE;
            busy   <= 0;
            done   <= 0;
            y      <= 0;
            x_reg  <= 0;
            y_reg  <= 0;
            shift  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 0;
                    done <= 0;
                    if (enable) begin
                        x_reg <= {{(2*N-N){1'b0}}, x}; 
                        y_reg <= 0;
                        shift <= ((N - 1) / 3) * 3;
                        busy  <= 1;
                        state <= WORK;
                    end
                end

                WORK: begin
                    y_shift = (y_reg << 1); 
                    b = ( (3 * y_shift * (y_shift + 1)) + 1 ) << shift; 

                    if (x_reg >= b) begin
                        x_reg <= x_reg - b;
                        y_reg <= y_shift + 1;
                    end else begin
                        y_reg <= y_shift;
                    end

                    if (shift == 0)
                        state <= DONE_STATE;
                    else
                        shift <= shift - 3;
                end

                DONE_STATE: begin
                    y     <= y_reg[N-1:0];
                    busy  <= 0;
                    done  <= 1;
                    if (!enable) begin
                        state <= IDLE;
                        done  <= 0;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule

