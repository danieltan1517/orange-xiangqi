main :: () {
  win := create_window(width, height, "Xiangqi");
  simp.set_render_target(win);
  xiangqi_startpos(*xiangqi);

  center_x = cast(float) width / 2.0;
  center_y = cast(float) height / 2.0;
  init_textures();
  ui_init();

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

    for event: events_this_frame {
      if event.type == .QUIT then {
        break render_loop;
      }
      getrect_handle_event(event);
    }

    render_xiangqiboard();
    render_ui();
    sleep_milliseconds(10);
    simp.swap_buffers(win);
    reset_temporary_storage();
  }

  
  init_textures :: () #expand {
    success := simp.texture_load_from_file(*sprites, "data/xiangqi.png");
    assert(success);
  }

  render_ui :: () #expand {
    time := get_time();
    ui_per_frame_update(win, width, height, time);
    k := height * 0.05;
    r := get_rect(5.0, height - 5.0 - k, 8.5*k, k);
    if base_checkbox(r, "Romanized", !chinese_pieces) then {
      chinese_pieces = !chinese_pieces;
    }
    r.y -= k + 5.0;
    if base_checkbox(r, "Orientation", !orient) then {
      orient = !orient;
    }
  }

  render_xiangqiboard :: () #expand {
    simp.clear_render_target(.15, .15, .15, 1.0);
    simp.set_shader_for_color();
    board_margin := min(center_x, center_y) * .925;
    sq := board_margin / 5.0;
    hsq := sq / 2.0; //hsq = half square
    board_x := center_x - sq * 4.5;
    board_y := center_y - sq * 5.0;
    color := Vector4.{1., 1., 1., 1.};
    simp.immediate_quad(board_x, board_y, board_x + 9.0 * sq, board_y + 10.0 * sq, color);
    simp.set_shader_for_images(*sprites);

    board_x += hsq;
    board_y += hsq;

    // draw the palace
    render_palace(board_x, board_y, sq, color);

    // draw the board itself.
    row := 0.0;
    while row < 8.0 {
      column := 0.0;
      gridx := board_x + row*sq; 
      while column < 9.0 {

        // 1/7, 1/5
        uv0 := make_vector2(0.0,     0.0);
        uv1 := make_vector2(1.0/7.0, 0.0);
        uv2 := make_vector2(1.0/7.0, 1.0/5.0);
        uv3 := make_vector2(0,       1.0/5.0);

        gridy := board_y + column*sq;
        immediate_quad(gridx, gridy, gridx + sq, gridy + sq, color, uv0, uv1, uv2, uv3);
        column += 1.0;

        // ignore the river and do not draw the river
        if column == 4.0 then
          column += 1.0;
      }

      row += 1.0;
    }

    board_x -= hsq;
    board_y -= hsq;

    // draw all the pieces.
    for piece_array, turn: xiangqi.pieces {
      gen := piece_array.general[0];
      gen = orient_piece(gen);
      render_piece(board_x, board_y, sq, gen, 0.0, turn, color);

      for adv: piece_array.advisors {
        adv = orient_piece(adv);
        render_piece(board_x, board_y, sq, adv, 1.0, turn, color);
      }

      for ele: piece_array.elephants {
        ele = orient_piece(ele);
        render_piece(board_x, board_y, sq, ele, 3.0, turn, color);
      }

      for kni: piece_array.knights {
        kni = orient_piece(kni);
        render_piece(board_x, board_y, sq, kni, 2.0, turn, color);
      }

      for rook: piece_array.rooks {
        rook = orient_piece(rook);
        render_piece(board_x, board_y, sq, rook, 4.0, turn, color);
      }

      for can: piece_array.cannons {
        can = orient_piece(can);
        render_piece(board_x, board_y, sq, can, 5.0, turn, color);
      }

      for sol: piece_array.soldiers {
        sol = orient_piece(sol);
        render_piece(board_x, board_y, sq, sol, 6.0, turn, color);
      }

    }
  }

  render_palace :: (board_x: float, board_y: float, sq: float, color: Vector4) #expand {

    palace_x := board_x + 3.0 * sq;
    palace_y := board_y + 0.0 * sq;
    // 1/7, 1/5
    uv0 := make_vector2(1.0/7.0, 0.0/5.0);
    uv1 := make_vector2(2.0/7.0, 0.0/5.0);
    uv2 := make_vector2(2.0/7.0, 1.0/5.0);
    uv3 := make_vector2(1.0/7.0, 1.0/5.0);
    immediate_quad(palace_x, palace_y, palace_x + sq, palace_y + sq, color, uv0, uv1, uv2, uv3);
    immediate_quad(palace_x + sq, palace_y + sq, palace_x + sq + sq, palace_y + sq + sq, color, uv0, uv1, uv2, uv3);

    palace_y += 7.0 * sq;
    immediate_quad(palace_x, palace_y, palace_x + sq, palace_y + sq, color, uv0, uv1, uv2, uv3);
    immediate_quad(palace_x + sq, palace_y + sq, palace_x + sq + sq, palace_y + sq + sq, color, uv0, uv1, uv2, uv3);

    palace_x = board_x + 5.0 * sq;
    palace_y = board_y + 0.0 * sq;
    immediate_quad(palace_x, palace_y, palace_x - sq, palace_y + sq, color, uv0, uv1, uv2, uv3);
    immediate_quad(palace_x - sq - sq, palace_y + sq + sq, palace_x - sq, palace_y + sq, color, uv0, uv1, uv2, uv3);

    palace_y += 7.0 * sq;
    immediate_quad(palace_x, palace_y, palace_x - sq, palace_y + sq, color, uv0, uv1, uv2, uv3);
    immediate_quad(palace_x - sq - sq, palace_y + sq + sq, palace_x - sq, palace_y + sq, color, uv0, uv1, uv2, uv3);

    uv0 = make_vector2(5.0/7.0, 0.0/5.0);
    uv1 = make_vector2(6.0/7.0, 0.0/5.0);
    uv2 = make_vector2(6.0/7.0, 1.0/5.0);
    uv3 = make_vector2(5.0/7.0, 1.0/5.0);

    river_x := board_x + 0.0 * sq;
    river_y := board_y + 4.0 * sq;

    immediate_quad(river_x, river_y, river_x + sq, river_y + sq, color, uv0, uv1, uv2, uv3);
    river_x += 8.0 * sq;
    immediate_quad(river_x, river_y, river_x - sq, river_y + sq, color, uv0, uv1, uv2, uv3);
  }

  render_piece :: (board_x: float, board_y: float, sq: float, from: u8, sprite_x: float, turn: s64, color: Vector4) {

    row, col := row_col_of(from);
    index_x := cast(float) row;
    index_y := cast(float) col;
    sprite_y := 2.0 - cast(float)turn;

    gridx := board_x + index_x*sq; 
    gridy := board_y + index_y*sq;
    if chinese_pieces then
      sprite_y += 2.0;

    uv0 := make_vector2(sprite_x*1.0/7.0, sprite_y*1.0/5.0);
    uv1 := make_vector2((sprite_x+1.0)*1.0/7.0, sprite_y*1.0/5.0);
    uv2 := make_vector2((sprite_x+1.0)*1.0/7.0, (sprite_y+1.0)*1.0/5.0);
    uv3 := make_vector2(sprite_x*1.0/7.0, (sprite_y+1.0)*1.0/5.0);

    immediate_quad(gridx, gridy, gridx + sq, gridy + sq, color, uv0, uv1, uv2, uv3);
  }
}

#scope_file
width:  s32 = 680;
height: s32 = 480;
sprites: simp.Texture;
center_x: float = 0.0;
center_y: float = 0.0;
xiangqi: Xiangqi;
moves: Moves;

immediate_quad :: (x0: float, y0: float, x1: float, y1: float, color: Vector4, uv0: Vector2, uv1: Vector2, uv2: Vector2, uv3: Vector2) {
  p0 := make_vector2(x0, y0);    
  p3 := make_vector2(x0, y1);
  p2 := make_vector2(x1, y1);
  p1 := make_vector2(x1, y0);
  simp.immediate_quad(p0, p1, p2, p3, color, uv0, uv1, uv2, uv3);
}

chinese_pieces := false;
orient := false;

orient_piece :: (index: u8) -> u8 {
  if orient == true then
    return orient_index(index);
  return index;
}

#import "Window_Creation";
#import "System";
#import "Basic";
simp :: #import "Simp";
#import "Input";
#import "Math";
#import "GetRect";
#load "movegen.jai";
