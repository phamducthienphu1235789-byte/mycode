// --- MODULE 1: BỘ ĐẾM TỐI ƯU (7-BIT) ---
module down_counter_opt (
    input wire clk,
    input wire rst_n,
    input wire load_en,
    input wire [6:0] load_val, // Tối ưu: Chỉ dùng 7 bit (Max 127)
    output wire done
);
    reg [6:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            count <= 0;
        else if (load_en) 
            count <= load_val;
        else if (count != 0) 
            count <= count - 1;
    end

    assign done = (count == 0);
endmodule

// --- MODULE 2: BỘ ĐIỀU KHIỂN RÚT GỌN ---
module traffic_light_opt (
    input wire clk,
    input wire rst_n,
    input wire [1:0] mode,      // 00:30s, 01:60s, 10:90s
    output wire [1:0] light_out // Tối ưu: Chỉ tốn 2 chân IO
);

    // Định nghĩa trạng thái trùng với mã hóa đầu ra để tiết kiệm logic
    localparam RED    = 2'b00;
    localparam GREEN  = 2'b01;
    localparam YELLOW = 2'b10;

    reg [1:0] state, next_state;
    reg [6:0] time_val;
    wire timer_done;

    // Instance bộ đếm
    down_counter_opt counter (
        .clk(clk),
        .rst_n(rst_n),
        .load_en(timer_done), // Khi đếm xong tự động nạp giá trị mới
        .load_val(time_val),  // Giá trị nạp phụ thuộc logic bên dưới
        .done(timer_done)
    );

    // --- LOGIC 1: ĐIỀU KHIỂN TRẠNG THÁI (Sequential) ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= RED;
        else        state <= next_state;
    end

    // --- LOGIC 2: TÍNH TOÁN TRẠNG THÁI TIẾP THEO & THỜI GIAN ---
    // Logic tổ hợp gộp chung để bộ tổng hợp (Synthesizer) tối ưu LUT
    always @(*) begin
        // Mặc định giữ trạng thái
        next_state = state;
        time_val   = 7'd29; // Giá trị mặc định an toàn (30s - 1 chu kỳ)

        case (state)
            RED: begin
                // Đang Đỏ, đếm xong thì qua Xanh
                if (timer_done) next_state = GREEN;
                
                // Logic chuẩn bị thời gian cho trạng thái TIẾP THEO (Xanh)
                // Green = Red_Time - 5s
                case (mode)
                    2'b00: time_val = 25; // Mode 30s -> Green 25s
                    2'b01: time_val = 55; // Mode 60s -> Green 55s
                    2'b10: time_val = 85; // Mode 90s -> Green 85s
                    default: time_val = 25;
                endcase
            end

            GREEN: begin
                // Đang Xanh, đếm xong thì qua Vàng
                if (timer_done) next_state = YELLOW;
                
                // Chuẩn bị thời gian cho Vàng (Cố định 5s)
                time_val = 5; 
            end

            YELLOW: begin
                // Đang Vàng, đếm xong thì qua Đỏ
                if (timer_done) next_state = RED;

                // Chuẩn bị thời gian cho Đỏ (30/60/90)
                case (mode)
                    2'b00: time_val = 30;
                    2'b01: time_val = 60;
                    2'b10: time_val = 90;
                    default: time_val = 30;
                endcase
            end
            
            default: next_state = RED;
        endcase
    end

    // --- LOGIC 3: ĐẦU RA (Zero Logic Cost) ---
    // Nối dây trực tiếp từ thanh ghi trạng thái ra chân output
    // Không tốn thêm Flip-Flop hay cổng logic nào.
    assign light_out = state;

endmodule
