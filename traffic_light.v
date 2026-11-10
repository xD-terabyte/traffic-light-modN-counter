// Mod-10 counter + Moore traffic-light FSM

module mod10_counter (
    input        clk,
    input        rst,
    output reg [3:0] q,
    output       tc
);
    assign tc = (q == 4'd9);

    always @(posedge clk) begin
        if (rst || q == 4'd9)
            q <= 4'd0;
        else
            q <= q + 4'd1;
    end
endmodule

module traffic_light (
    input  clk,
    input  rst,
    output red,
    output yellow,
    output green
);
    localparam G = 2'b00, Y = 2'b01, R = 2'b10;

    reg  [1:0] state;
    wire [3:0] count;
    wire       tc;

    mod10_counter timer (.clk(clk), .rst(rst), .q(count), .tc(tc));

    always @(posedge clk) begin
        if (rst)
            state <= G;
        else if (tc) begin
            case (state)
                G:       state <= Y;
                Y:       state <= R;
                R:       state <= G;
                default: state <= G;
            endcase
        end
    end

    // Moore outputs
    assign green  = (state == G);
    assign yellow = (state == Y);
    assign red    = (state == R);
endmodule

// Testbench
module tb;
    reg clk = 0, rst = 1;
    wire red, yellow, green;

    traffic_light dut (.clk(clk), .rst(rst), .red(red), .yellow(yellow), .green(green));

    always #5 clk = ~clk;

    initial begin
        $monitor("t=%0t R=%b Y=%b G=%b", $time, red, yellow, green);
        #12 rst = 0;
        #400 $finish;
    end
endmodule
