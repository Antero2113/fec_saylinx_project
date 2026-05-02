module formula #(
    parameter N = 8
) (
    input  wire           clk,
    input  wire           rst,
    input  wire           enable,
    input  wire [N-1:0]   a,
    input  wire [N-1:0]   b,
    output reg  [N-1:0]   y,
    output reg            done
);

    localparam Y_CBRT_OUT_WIDTH = (N/3 + ((N%3)!=0));
    localparam SUM_W = N + Y_CBRT_OUT_WIDTH;         
    localparam Y_SQRT_OUT_WIDTH = (SUM_W/2 + ((SUM_W%2)!=0)); 

    reg  [N-1:0] a_reg, b_reg;
    reg  [Y_CBRT_OUT_WIDTH-1:0] sbrt_b_reg; 
    reg  [SUM_W-1:0] sum_ab_reg;             
    
    reg enable_sbrt;
    reg enable_sqrt;

    wire [Y_CBRT_OUT_WIDTH-1:0] sbrt_b_val;  
    wire [Y_SQRT_OUT_WIDTH-1:0] sqrt_result; 
    wire done_sbrt, busy_sbrt;
    wire done_sqrt, busy_sqrt;

    localparam [2:0]
        IDLE        = 3'd0,
        START_CBRT  = 3'd1,
        WAIT_CBRT   = 3'd2,
        START_SQRT  = 3'd3,
        WAIT_SQRT   = 3'd4,
        DONE_STATE  = 3'd5;

    reg [2:0] state;
    reg [15:0] timeout_counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            enable_sbrt <= 1'b0;
            enable_sqrt <= 1'b0;
            done <= 1'b0;
            y <= {N{1'b0}};
            a_reg <= {N{1'b0}};
            b_reg <= {N{1'b0}};
            sbrt_b_reg <= {Y_CBRT_OUT_WIDTH{1'b0}};
            sum_ab_reg <= {SUM_W{1'b0}};
            timeout_counter <= 0;
            
        end else begin
            case (state)
                IDLE: begin
                    enable_sbrt <= 1'b0;
                    enable_sqrt <= 1'b0;
                    done <= 1'b0;
                    timeout_counter <= 0;
                    if (enable) begin
                        a_reg <= a;
                        b_reg <= b;
                        
                        state <= START_CBRT;
                    end
                end

                START_CBRT: begin
                    enable_sbrt <= 1'b1; 
                    timeout_counter <= 0;
                    
                    state <= WAIT_CBRT;
                end

                WAIT_CBRT: begin
                    enable_sbrt <= 1'b1;
                    timeout_counter <= timeout_counter + 1;
                    if (done_sbrt) begin
                        sbrt_b_reg <= sbrt_b_val;
                        sum_ab_reg <= {{(SUM_W-N){1'b0}}, a_reg} + {{(SUM_W-Y_CBRT_OUT_WIDTH){1'b0}}, sbrt_b_val};
                        y <= {{N-Y_CBRT_OUT_WIDTH{1'b0}}, sbrt_b_val};
                        enable_sbrt <= 1'b0;
                        
                        state <= START_SQRT;
                        timeout_counter <= 0;
                    end else if (timeout_counter > 20000) begin
                        enable_sbrt <= 1'b0;
                        state <= IDLE;
                    end
                end

                START_SQRT: begin
                    enable_sqrt <= 1'b1; 
                    timeout_counter <= 0;
                    state <= WAIT_SQRT;
                end

                WAIT_SQRT: begin
                    enable_sqrt <= 1'b1;
                    timeout_counter <= timeout_counter + 1;
                    if (done_sqrt) begin
                        y <= {{N-Y_SQRT_OUT_WIDTH{1'b0}}, sqrt_result};
                        done <= 1'b1;
                        enable_sqrt <= 1'b0;
                        
                        state <= DONE_STATE;
                        timeout_counter <= 0;
                    end else if (timeout_counter > 20000) begin
                        enable_sqrt <= 1'b0;
                        state <= IDLE;
                    end
                end

                DONE_STATE: begin
                    done <= 1'b1;
                    if (!enable) begin
                        state <= IDLE;
                        done <= 1'b0;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

    cbrt #(.N(N)) sbrt_mod (
        .clk(clk),
        .rst(rst),
        .enable(enable_sbrt),
        .x(b_reg), 
        .y(sbrt_b_val), 
        .done(done_sbrt),
        .busy(busy_sbrt)
    );

    sqrt #(.N(SUM_W)) sqrt_mod ( 
        .clk(clk),
        .rst(rst),
        .enable(enable_sqrt),
        .x(sum_ab_reg),
        .y(sqrt_result), 
        .done(done_sqrt),
        .busy(busy_sqrt)
    );
endmodule
