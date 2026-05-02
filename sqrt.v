module sqrt #(
    parameter N = 8
) (
    input  wire           clk,
    input  wire           rst,    
    input  wire           enable,
    input  wire [N-1:0]   x,
    output reg  [(N/2):0] y, 
    output reg            done,
    output reg            busy
);

    localparam IDLE       = 2'b00;
    localparam WORK       = 2'b01;
    localparam DONE_STATE = 2'b10;

    reg [1:0] state;
    
    reg [N-1:0] x_reg;
    reg [(N/2):0] cand;
    reg [(N/2):0] y_reg;
    wire [N-1:0] cand_squared;
    
    assign cand_squared = (cand * cand);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state  <= IDLE;
            busy   <= 0;
            done   <= 0;
            y      <= 0;
            x_reg  <= 0;
            y_reg  <= 0;
            cand   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 0;
                    done <= 0;
                    if (enable) begin
                        x_reg <= x;
                        y_reg <= 0;
                        cand <= 0;
                        busy  <= 1;
                        state <= WORK;
                    end
                end

                WORK: begin
                    if (cand_squared <= x_reg) begin
                        if (cand == ((1 << ((N/2) + 1)) - 1)) begin
                            y_reg <= cand;
                            state <= DONE_STATE;
                        end else begin
                            cand <= cand + 1;
                        end
                    end else begin
                        if (cand == 0) begin
                            y_reg <= 0;
                        end else begin
                            y_reg <= cand - 1;
                        end
                        state <= DONE_STATE;
                    end
                end

                DONE_STATE: begin
                    y     <= y_reg[(N/2):0];
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
