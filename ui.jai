#scope_file
width:  s32 = 680;
height: s32 = 480;
sprites: simp.Texture;
center_x: float = 0.0;
center_y: float = 0.0;

#scope_export
main :: () {
  win := create_window(width, height, "Xiangqi");
  simp.set_render_target(win);

  center_x = cast(float) width / 2.0;
  center_y = cast(float) height / 2.0;

  init_textures();
  while render_loop := true {
    update_window_events();
    for get_window_resizes() {
      if it.window == win {
        width  = it.width;
        height = it.height;
        center_x = cast(float) width / 2.0;
        center_y = cast(float) height / 2.0;
        simp.update_window(win);
      }
    }

    for events_this_frame {
      if it.type == .QUIT then {
        break render_loop;
      }
    }

    render();
    sleep_milliseconds(10);
    simp.swap_buffers(win);
    reset_temporary_storage();
  }

  
  init_textures :: () #expand {
    success := simp.texture_load_from_file(*sprites, "data/xiangqi.png");
    assert(success);
  }

  render :: () #expand {
    simp.clear_render_target(.8, .8, .8, 1.0);
    simp.set_shader_for_color();
    board_margin := min(center_x, center_y) * .925;
    sq := board_margin / 5.5;
    hsq := sq / 2.0; //hsq = half square
    board_x := center_x - sq * 5.0;
    board_y := center_y - sq * 5.5;
    color := Vector4.{1,1,1,1};
    simp.immediate_quad(board_x, board_y, board_x + 10.0 * sq, board_y + 11.0 * sq, color);
    simp.set_shader_for_images(*sprites);

    board_x += hsq;
    board_y += hsq;

    row := 0.0;
    while row < 9.0 {
      column := 0.0;
      gridx := board_x + row*sq; 
      while column < 10.0 {
        // 1/7, 1/5
        uv0 := make_vector2(0.0,     0.0);
        uv1 := make_vector2(1.0/7.0, 0.0);
        uv2 := make_vector2(1.0/7.0, 1.0/5.0);
        uv3 := make_vector2(0,       1.0/5.0);

        gridy := board_y + column*sq;
        immediate_quad(gridx, gridy, gridx + sq, gridy + sq, color, uv0, uv1, uv2, uv3);
        column += 1.0;
      }

      row += 1.0;
    }

    board_x -= hsq;
    board_y -= hsq;

    render_piece(board_x, board_y, sq, 0.0, 0.0, color);
    render_piece(board_x, board_y, sq, 9.0, 0.0, color);
    
  }

  render_piece :: (board_x: float, board_y: float, sq: float, index_x: float, index_y: float, color: Vector4) {
    gridx := board_x + index_x*sq; 
    gridy := board_y + index_y*sq;
    uv0 := make_vector2(4*1.0/7.0, 2*1.0/5.0);
    uv1 := make_vector2(5*1.0/7.0, 2*1.0/5.0);
    uv2 := make_vector2(5*1.0/7.0, 3*1.0/5.0);
    uv3 := make_vector2(4*1.0/7.0, 3*1.0/5.0);
    immediate_quad(gridx, gridy, gridx + sq, gridy + sq, color, uv0, uv1, uv2, uv3);
  }
}

immediate_quad :: (x0: float, y0: float, x1: float, y1: float, color: Vector4, uv0: Vector2, uv1: Vector2, uv2: Vector2, uv3: Vector2) {
  p0 := make_vector2(x0, y0);    
  p3 := make_vector2(x0, y1);
  p2 := make_vector2(x1, y1);
  p1 := make_vector2(x1, y0);
  simp.immediate_quad(p0, p1, p2, p3, color, uv0, uv1, uv2, uv3);
}



#scope_file
#import "Window_Creation";
#import "System";
#import "Basic";
simp :: #import "Simp";
#import "Input";
#import "Math";
