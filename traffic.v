module traffic (
  input wire clk,
  input wire rst,
  input wire [1:0] mode, //00: 5 clock; 01: 10 clock; 10: 12 clock 
  input wire ped_btn, // delay 20s sau khi bat danh cho nguoi di bo

  output reg [1:0] light_east, //dong
  output reg [1:0] light_north,//bac
  output reg [1:0] light_west, //tay
  output reg [1:0] light_south, //nam

  output reg [1:0] light_ped
);
  localparam green  = 2'b00 ;
  localparam yellow = 2'b01 ;
  localparam red    = 2'b10 ;

  localparam east_green   = 4'd0;
  localparam east_yellow  = 4'd1;
  localparam north_green  = 4'd2;
  localparam north_yellow = 4'd3;
  localparam west_green   = 4'd4;
  localparam west_yellow  = 4'd5;
  localparam south_green  = 4'd6;
  localparam south_yellow = 4'd7;
  localparam ped_walk     = 4'd8;

  reg [3:0] time_green ;// khai bao la reg de thay doi khi dau vao thay doi
  
  localparam time_yellow = 4'd3 ;
  localparam time_ped  = 4'd10 ;

  //phan khia bao dung cho den nguoi di bo
  reg ped_pending; // co nguoi dang doi hay khong
  reg [1:0] last_side; // huong den xanh dang bat khi co nguoi nhan ped_btn de biet n_state la huong nao

  reg [3:0] c_state, n_state;
  reg [3:0] timer;
  
  assign counter = timer;
// bo cai thoi gian cho time_green theo mode dau vao
  always @(*) begin
    case (mode)
      2'b00: time_green = 4'd5;
      2'b01: time_green = 4'd10;
      2'b10: time_green = 4'd12;

      default: time_green = 4'd10;
    endcase
  end
// sequential logic
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      c_state     <= east_green;
      timer       <= 0;
      ped_pending <= 0;
      last_side   <= 0;
    end else begin
      c_state <= n_state;
      if (c_state != n_state) begin
        timer <= 0;
      end else begin
        timer <= timer + 1;
      end
      if (ped_btn) begin
        ped_pending <= 1'b1;
      end else if (c_state == ped_walk) begin
        ped_pending <= 1'b0;
      end
      case (c_state)
        east_yellow : last_side <= 0;
        north_yellow: last_side <= 1;
        west_yellow : last_side <= 2;
        south_yellow: last_side <= 3;
      endcase
    end 
  end

// cac trang thai tiep theo
  always @(*) begin
    n_state = c_state;
    case (c_state)
      east_green:   if (timer >= time_green - 1)  n_state = east_yellow;
      east_yellow:  if (timer >= time_yellow - 1) begin
        if (ped_pending) n_state = ped_walk;
        else             n_state = north_green;
      end
      north_green:  if (timer >= time_green - 1)  n_state = north_yellow;
      north_yellow: if (timer >= time_yellow - 1) begin
        if (ped_pending) n_state = ped_walk;
        else             n_state = west_green;
      end
      west_green:   if (timer >= time_green - 1)  n_state = west_yellow;
      west_yellow:  if (timer >= time_yellow - 1) begin
        if (ped_pending) n_state = ped_walk;
        else             n_state = south_green;
      end
      south_green:  if (timer >= time_green - 1)  n_state = south_yellow;
      south_yellow: if (timer >= time_yellow - 1) begin
        if (ped_pending) n_state = ped_walk;
        else             n_state = east_green;
      end
      ped_walk: begin
        if (timer >= time_ped - 1) begin
          case (last_side)
            0: n_state = north_green;
            1: n_state = west_green;
            2: n_state = south_green;
            3: n_state = east_green;
            default: n_state = east_green;
          endcase
        end
      end
      default: n_state = east_green;
    endcase
  end
// output logic
  always @(*) begin
    light_east  = red;
    light_north = red;
    light_south = red;
    light_west  = red;
    light_ped   = red;
    case (c_state)
      east_green:   light_east  = green;
      east_yellow:  light_east  = yellow;

      north_green:  light_north = green;
      north_yellow: light_north = yellow;
      
      west_green:   light_west  = green;
      west_yellow:  light_west  = yellow;
      
      south_green:  light_south = green;
      south_yellow: light_south = yellow;
    
      ped_walk: begin
        light_ped = green;
      end
    endcase
  end
endmodule
