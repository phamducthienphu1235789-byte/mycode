module Traffic_Controller_Optimized (
    input  wire clk,
    input  wire rst,
    // Chỉ còn đúng 4 dây ngõ ra hiển thị mã trạng thái
    output wire [3:0] traffic_phase 
);

    // --- 1. ĐỊNH NGHĨA TRẠNG THÁI (MÃ HÓA) ---
    // Ta gán thẳng giá trị số cho trạng thái để dễ hình dung
    localparam [2:0] 
        PHASE_S_LEFT      = 3'd0,
        PHASE_N_LEFT      = 3'd1,
        PHASE_NS_STRAIGHT = 3'd2,
        PHASE_NS_YELLOW   = 3'd3,
        PHASE_E_LEFT      = 3'd4,
        PHASE_W_LEFT      = 3'd5,
        PHASE_EW_STRAIGHT = 3'd6,
        PHASE_EW_YELLOW   = 3'd7;

    // Tham số thời gian (Giả lập)
    parameter T_LEFT     = 15; 
    parameter T_STRAIGHT = 30;
    parameter T_YELLOW   = 5;

    reg [2:0] current_state, next_state;
    reg [31:0] counter, max_count;
    wire time_done;

    // --- 2. LOGIC BỘ ĐẾM & TIMER (Giữ nguyên) ---
    always @(*) begin
        case (current_state)
            PHASE_S_LEFT, PHASE_N_LEFT, PHASE_E_LEFT, PHASE_W_LEFT: 
                max_count = T_LEFT;
            PHASE_NS_STRAIGHT, PHASE_EW_STRAIGHT: 
                max_count = T_STRAIGHT;
            default: // Yellow states
                max_count = T_YELLOW;
        endcase
    end

    assign time_done = (counter >= max_count - 1);

    always @(posedge clk or negedge rst) begin
        if (!rst) counter <= 0;
        else begin
            if (time_done) counter <= 0;
            else counter <= counter + 1;
        end
    end

    // --- 3. MÁY TRẠNG THÁI (FSM) ---
    always @(posedge clk or negedge rst) begin
        if (!rst) current_state <= PHASE_S_LEFT;
        else current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state;
        if (time_done) begin
            case (current_state)
                PHASE_S_LEFT:      next_state = PHASE_N_LEFT;
                PHASE_N_LEFT:      next_state = PHASE_NS_STRAIGHT;
                PHASE_NS_STRAIGHT: next_state = PHASE_NS_YELLOW;
                PHASE_NS_YELLOW:   next_state = PHASE_E_LEFT;
                
                PHASE_E_LEFT:      next_state = PHASE_W_LEFT;
                PHASE_W_LEFT:      next_state = PHASE_EW_STRAIGHT;
                PHASE_EW_STRAIGHT: next_state = PHASE_EW_YELLOW;
                PHASE_EW_YELLOW:   next_state = PHASE_S_LEFT;
                default:           next_state = PHASE_S_LEFT;
            endcase
        end
    end

    // --- 4. NGÕ RA (TỐI ƯU HÓA) ---
    // Xuất thẳng trạng thái hiện tại ra ngoài.
    // Bit số 3 luôn bằng 0 vì ta chỉ dùng đến số 7 (111).
    assign traffic_phase = {1'b0, current_state};

endmodule
