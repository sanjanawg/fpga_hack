module uart_re(
    input clk,               // Clock input
    input reset,             // Reset button
    input [3:0] switches,    // SW[3:0] for item select
    input button,            // Button input to trigger servo movement
    output reg [6:0] seg,    // 7-segment display (HEX0)
    output reg [7:0] leds,   // LEDs for status
    output reg servo_pwm     // PWM signal to control the servo motor
);

    // State encoding
    parameter IDLE     = 2'b00;
    parameter PRICE    = 2'b01;
    parameter DISPENSE = 2'b10;

    reg [1:0] state, next_state;
    
    // PWM signal generation
    reg [15:0] pwm_counter;  // PWM counter
    reg [15:0] pwm_duty;     // PWM duty cycle for servo (1/100th of the period)

    // Item prices (in arbitrary units)
    reg [3:0] item_prices [0:3]; 
    reg [3:0] current_price;

    // 7-segment display decoder (hexadecimal)
    always @(*) begin
        case (current_price)
            4'd0: seg = 7'b1000000; // "0"
            4'd1: seg = 7'b1111001; // "1"
            4'd2: seg = 7'b0100100; // "2"
            4'd3: seg = 7'b0110000; // "3"
            4'd4: seg = 7'b0011001; // "4"
            4'd5: seg = 7'b0010010; // "5"
            4'd6: seg = 7'b0000010; // "6"
            4'd7: seg = 7'b1111000; // "7"
            4'd8: seg = 7'b0000000; // "8"
            4'd9: seg = 7'b0010000; // "9"
            default: seg = 7'b1111111; // Blank
        endcase
    end

    // PWM signal generation for the servo
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_counter <= 16'b0;
            servo_pwm <= 0;
        end else begin
            pwm_counter <= pwm_counter + 1;
            if (pwm_counter < pwm_duty)
                servo_pwm <= 1;
            else
                servo_pwm <= 0;
        end
    end

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next-state logic and outputs
    always @(*) begin
        // Default values
        next_state = state;
        leds = 8'b0; // Clear all LEDs
        pwm_duty = 16'd1000; // Default PWM duty cycle for IDLE state (no servo movement)
        current_price = 4'd0; // Initialize current_price to 0

        case (state)
            IDLE: begin
                leds[0] = 1; // Idle LED
                if (switches != 4'b0000) begin
                    // Item is selected, set price
                    current_price = item_prices[switches];
                    next_state = PRICE;
                end
            end

            PRICE: begin
                leds[1] = 1; // Price LED
                if (button) begin
                    next_state = DISPENSE;  // Transition to DISPENSE when button is pressed
                end
            end

            DISPENSE: begin
                leds[2] = 1; // Dispensing LED
                pwm_duty = 16'd1500; // Set PWM duty cycle for servo at 90 degrees
                next_state = IDLE; // Go back to idle after dispensing
            end

            default: next_state = IDLE;
        endcase
    end

    // Initialize prices for the items (no payment logic)
    initial begin
        item_prices[0] = 4'd3; // Item 0: 3 units
        item_prices[1] = 4'd5; // Item 1: 5 units
        item_prices[2] = 4'd7; // Item 2: 7 units
        item_prices[3] = 4'd9; // Item 3: 9 units
    end

endmodule
