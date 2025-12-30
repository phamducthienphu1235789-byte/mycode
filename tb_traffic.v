`timescale 1ns / 1ps

module tb_traffic;

    // 1. Khai báo tín hiệu nối với DUT
    reg clk;
    reg rst;
    reg [1:0] mode;      // Input chọn thời gian
    reg ped_btn;         // Input nút người đi bộ

    wire [1:0] light_east;
    wire [1:0] light_north;
    wire [1:0] light_west;
    wire [1:0] light_south;
    wire [1:0] light_ped;

    // 2. Gọi module traffic (DUT)
    traffic uut (
        .clk(clk),
        .rst(rst),
        .mode(mode),
        .ped_btn(ped_btn),
        .light_east(light_east),
        .light_north(light_north),
        .light_west(light_west),
        .light_south(light_south),
        .light_ped(light_ped)
    );

    // 3. Tạo Clock (Chu kỳ 10ns -> 100MHz)
    always #5 clk = ~clk;

    // Task hỗ trợ nhấn nút (để code gọn hơn)
    task press_ped_button;
        begin
            ped_btn = 0;
            #20;
            ped_btn = 1; // Nhấn nút
            $display("--- [Action] Nguoi di bo nhan nut tai %t ---", $time);
            #20;         // Giữ 2 chu kỳ
            ped_btn = 0; // Nhả nút
        end
    endtask

    // 4. Kịch bản Test
    initial begin
        // --- Khởi tạo ---
        clk = 0;
        rst = 0;       // Reset tích cực thấp (theo code của bạn: if (!rst))
        mode = 2'b00;  // Mode 0: Green time = 5
        ped_btn = 0;

        // --- Giai đoạn 1: Reset hệ thống ---
        $display("--- Bat dau mo phong ---");
        #20;
        rst = 1;       // Nhả reset
        $display("Da nha Reset. Mode = 00 (Green=5s)");

        // --- Giai đoạn 2: Quan sát chạy bình thường (Mode 0) ---
        // Đợi đủ lâu để nó chuyển qua vài trạng thái (Đông -> Bắc)
        // East Green (5) + Yellow (3) + North Green (5) ...
        #150; 

        // --- Giai đoạn 3: Test Người đi bộ (Pedestrian) ---
        // Đang chạy bình thường, giả sử nhấn nút lúc đang ở hướng Tây hoặc Nam
        press_ped_button();

        // Quan sát sóng: Sau khi hết pha vàng hiện tại, nó phải nhảy vào ped_walk (8)
        // ped_walk kéo dài 10 clock (#100ns)
        #200; 

        // --- Giai đoạn 4: Đổi Mode (Tăng thời gian đèn xanh) ---
        $display("--- [Action] Chuyen sang Mode 01 (Green=10s) ---");
        mode = 2'b01; 
        
        // Chạy thêm một lúc để xem thời gian đèn xanh có dài ra không
        #300;

        $display("--- Ket thuc mo phong ---");
        $finish;
    end

    // 5. Monitor (Theo dõi trạng thái dạng text)
    // Lưu ý: %d để in số thập phân, %b in nhị phân
    initial begin
        $monitor("Time=%t | Mode=%b | State(East/Ped)=%b/%b | Ped_Btn=%b", 
                 $time, mode, light_east, light_ped, ped_btn);
    end

endmodule
