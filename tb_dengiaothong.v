`timescale 1ns / 1ps

module tb_traffic;

    // 1. Khai báo tín hiệu
    // Reg cho đầu vào (để ta điều khiển)
    reg clk;
    reg rst;

    // Wire cho đầu ra (để ta quan sát)
    // Cụm Bắc
    wire n_red, n_yellow, n_green_left, n_green_straight;
    // Cụm Nam
    wire s_red, s_yellow, s_green_left, s_green_straight;
    // Cụm Đông
    wire e_red, e_yellow, e_green_left, e_green_straight;
    // Cụm Tây
    wire w_red, w_yellow, w_green_left, w_green_straight;

    // 2. Gọi Module chính (Unit Under Test - UUT)
    // QUAN TRỌNG: Ghi đè tham số thời gian để chạy mô phỏng nhanh
    Traffic_Controller_Full_4Way #(
        .T_LEFT(20),      // Giả lập rẽ trái trong 20 chu kỳ
        .T_STRAIGHT(40),  // Giả lập đi thẳng trong 40 chu kỳ
        .T_YELLOW(10)     // Giả lập vàng trong 10 chu kỳ
    ) uut (
        .clk(clk),
        .rst(rst),
        
        // Kết nối các chân
        .n_red(n_red), .n_yellow(n_yellow), .n_green_left(n_green_left), .n_green_straight(n_green_straight),
        .s_red(s_red), .s_yellow(s_yellow), .s_green_left(s_green_left), .s_green_straight(s_green_straight),
        .e_red(e_red), .e_yellow(e_yellow), .e_green_left(e_green_left), .e_green_straight(e_green_straight),
        .w_red(w_red), .w_yellow(w_yellow), .w_green_left(w_green_left), .w_green_straight(w_green_straight)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    initial begin
        // Bước 1: Khởi tạo và Reset
        rst = 0; // Kích hoạt Reset (Active Low)
        $display("Time: %0t | Simulation Start - Resetting...", $time);
        
        #50;     // Giữ Reset trong 50ns
        rst = 1; // Thả Reset ra để mạch chạy
        $display("Time: %0t | Reset released - System Running...", $time);

        // Bước 2: Chạy trong một khoảng thời gian đủ để quan sát hết chu trình

        #10000; 

        // Bước 3: Dừng mô phỏng
        $display("Time: %0t | Simulation Finished successfully.", $time);
        $stop; // Lệnh dừng của ModelSim
    end

    // 5. (Tùy chọn) In trạng thái ra màn hình console để dễ debug
    // In mỗi khi đèn đỏ hướng Bắc hoặc Đông thay đổi
    initial begin
        $monitor("Time: %0t | N_Red: %b | N_Left: %b | N_Straight: %b || E_Red: %b | E_Left: %b | E_Straight: %b", 
                 $time, n_red, n_green_left, n_green_straight, e_red, e_green_left, e_green_straight);
    end

endmodule
