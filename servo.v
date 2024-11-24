module try (
    input clk,    
    input rst,    
    input  x,
    output reg y
);

    
    parameter [2:0] s0 = 3'b000, 
                    s1 = 3'b001, 
                    s2 = 3'b010, 
                    s3 = 3'b011, 
                    s4 = 3'b100, 
                    s5 = 3'b101, 
                    s6 = 3'b110;

    reg [2:0] ps, ns;

    always @(posedge clk or posedge rst) begin
        if (rst)
            ps <= s0; 
        else
            ps <= ns; 
    end

  
    always @(*) begin
        case (ps)
            s0: ns = (x == 1) ? s1 : s0; 
            s1: ns = (x == 1) ? s2 : s0; 
            s2: ns = (x == 1) ? s3 : s2; 
            s3: ns = (x == 2) ? s4 : s2; 
            s4: ns = (x == 3) ? s5 : s2;
            s5: ns = s6;                
            s6: ns = s0;                
            default: ns = s0;          
        endcase
    end

    
    always @(*) begin
        case (ps)
            s0: y = 3'b000; 
            s1: y = 3'b000; 
            s2: y = 3'b000; 
            s3: y = 3'b000; 
            s4: y = 3'b000; 
            s5: y = 3'b000; 
            s6: y = 3'b001; 
            default: y = 3'b000;
        endcase
    end

endmodule

