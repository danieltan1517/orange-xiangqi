main :: () {
  path = copy_string(path_strip_filename(get_path_of_running_executable()));
  set_working_directory(path);
  set_default_theme(default_theme_procs[Default_Themes.Grayscale]());
  overall_theme_modify();
  win := create_window(cast(int) width, cast(int) height, "Xiangqi");
  simp.set_render_target(win);
  xiangqi_startpos(*xiangqi);
  reset(*moves);
  generate_moves(*xiangqi, *moves);
  array_reserve(*red_pv_lines, 200);
  array_reserve(*black_pv_lines, 200);
  filter_legal_moves(*xiangqi, *moves);

  init_sound(win);
  init_textures();
  ui_init();
  ctrl_pressed := 0;

  load_engines_at_startup();

  subwindow_newgame.rect = get_rect(50,50,580,580);
  subwindow_newgame.draw = draw_subwindow_newgame;
  subwindow_newgame.title_text = "New Game";
  subwindow_newgame.open = false;

  defer {
    for *engine: engines_array {
      close_engine(engine);
    }
  }

  while render_loop := true {
    dt = looptime_end - looptime_begin;
    clock_update();
    looptime_begin = looptime_end;
    update_window_events();
    for get_window_resizes() {
      if it.window == win {
        width  = cast(float) it.width;
        height = cast(float) it.height;

        // a bit of a supersition, use a golden section to determine
        // where to place the widgets.
        if cast(float)width > cast(float) height * SQRT2 {
          off_center = true;
        } else {
          off_center = false;
        }
        simp.update_window(win);
      }
    }

    mouse_x, mouse_y := get_mouse_pointer_position(win, true);
    mouse_event := false;
    key_pressed := 0;
    for e: events_this_frame {
      if e.type == .QUIT then {
        break render_loop;
      }
      getrect_handle_event(e);
      if e.type == .KEYBOARD then {
        if e.key_code == .MOUSE_BUTTON_LEFT {
          key_pressed = e.key_pressed;
          mouse_event = true;
          xiangqi_board_click(cast(float) mouse_x, cast(float) mouse_y, mouse_event, key_pressed, true);
        } else if e.key_code == .MOUSE_BUTTON_RIGHT {
          key_pressed = e.key_pressed;
          mouse_event = true;
          xiangqi_board_click(cast(float) mouse_x, cast(float) mouse_y, mouse_event, key_pressed, false);
        } else if e.key_code == .CTRL {
          ctrl_pressed = e.key_pressed;
        } else if e.key_pressed == 1 && e.key_code == #char "Z" && ctrl_pressed {
          gui_undo_move();
        } else if e.key_pressed == 1 && e.key_code == #char "Y" && ctrl_pressed {
          gui_redo_move();
        }
      }
    }

    // loop through engines and do engine logic.
    if moves.count then {
      for *engine, index: engines_array {
        protocol := ifx engine.protocol == .uci then "uci" else "ucci";
        update_ucci(engine, index, protocol);
      }
    }

    render_xiangqiboard(cast(float)mouse_x, cast(float)mouse_y, mouse_event);
    render_right_panel();
    render_ui();

    // sound effects.
    pre_entity_update(sound_player);
    for sound_player.streams  it.marked = true;
    post_entity_update(sound_player, dt);

    sleep_milliseconds(20);
    simp.swap_buffers(win);
    reset_temporary_storage();
    looptime_end = cast(float)get_time();
  }

  init_textures :: () #expand {
    success := simp.texture_load_from_file(*sprites, "data/xiangqi.png");
    assert(success);
    success  = simp.texture_load_from_file(*setting_sprite, "data/settings.png");
    assert(success);
  }

  xiangqi_board_click :: (x: float, y: float, mouse_event: bool, key_pressed: int, left_or_right: bool) {
    if subwindow_newgame.open {
      // outside of the board.
      xiangqi_mouse = XiangqiMouse.Idle; 
      xiangqi_highlight = .Idle;
      xiangqi_highlight_select = -1;
      from_index = 0xFF;
      return; // do not process board inputs when subwindows are open.
    }

    center_x: float = 0;
    center_y: float = 0;
    board_margin: float = 0;
    if off_center == true {
      center_x = height / 2.0;
      center_y = center_x;
      board_margin = center_x * .925;
    } else {
      center_x = width  / 2.0;
      center_y = height / 2.0;
      board_margin = min(center_x, center_y) * .925;
    }

    sq := board_margin / 5.0;
    hsq := sq / 2.0; //hsq = half square
    board_x := center_x - sq * 4.5;
    board_y := center_y - sq * 5.0;
    end_x := board_x + sq * 9.0;
    end_y := board_y + sq * 10.0;

    if mouse_event && x >= board_x && x <= end_x && y >= board_y && y <= end_y then {
      row := cast(u8) ((x - board_x) / sq);
      col := cast(u8) ((y - board_y) / sq);
      if orient then {
        row = 8 - row;
        col = 9 - col;
      }
      if left_or_right == true {
        xiangqi_highlight = .Idle;
        clear_arrows();
        if xiangqi_mouse == {
        case XiangqiMouse.Idle;
          if key_pressed == 1 then {
            piece := xiangqi.board_9x10[row][col];
            if piece != 0 then {
              xiangqi_mouse = XiangqiMouse.Drag;
              from_index = index_of(row, col);
            }
          }
       
        case XiangqiMouse.Drag;
          to_index := index_of(row, col);
          if from_index != to_index then {
            piece := xiangqi.board_9x10[row_of(from_index)][col_of(from_index)];
            capture := xiangqi.board_9x10[row][col];
            move := Move32.{from_index, to_index, capture, piece};
            gui_make_move(move, false);
            xiangqi_mouse = XiangqiMouse.Idle;
            from_index = 0xFF;
          } else {
            xiangqi_mouse = XiangqiMouse.Select;
          }
       
        case XiangqiMouse.Select;
          to_index := index_of(row, col);
          piece := xiangqi.board_9x10[row_of(from_index)][col_of(from_index)];
          capture := xiangqi.board_9x10[row][col];
          move := Move32.{from_index, to_index, capture, piece};
          gui_make_move(move, true);
          xiangqi_mouse = XiangqiMouse.Idle;
          from_index = 0xFF;
        }
      } else {
        position := index_of(row, col);
        if xiangqi_highlight == {
        case .Idle;
          if key_pressed == 1 {
            xiangqi_highlight_select = position;
            xiangqi_highlight = .Select;
          }
        case .Select;
          if key_pressed == 0 {
            if xiangqi_highlight_select != position {
              // add an arrow...
              arrow: Arrow;
              arrow.from = cast(u8) xiangqi_highlight_select;
              arrow.to   = cast(u8) position;
              add_arrow(arrow);
            }

            xiangqi_highlight = .Idle;
          }
        }

      }
    } else {
      // outside of the board.
      xiangqi_mouse = XiangqiMouse.Idle; 
      xiangqi_highlight = .Idle;
      xiangqi_highlight_select = -1;
      from_index = 0xFF;
    }
  }

  render_ui :: () #expand {
    text_theme  := *default_overall_theme.text_input_theme;
    label_theme := *default_overall_theme.label_theme;
    time := get_time();
    ui_per_frame_update(win, cast(s32) width, cast(s32) height, time);
    k := clamp(height * 0.05, 15.0, 45.0);
    r := get_rect(5.0, height - 5.0 - k, k, k);

    if button(r, "", texture=*setting_sprite) then {
      if subwindow_newgame.open == false {
        display_settings = !display_settings;
      }
    }

    if display_settings {
      r.x += 20.0;
      r.y -= 5.0;
      r.w = 8.5 * k;
      color := Vector4.{.05, .05, .05, .9};
      simp.set_shader_for_color(true);

      num_buttons :: 14.0;
      simp.immediate_quad(17.0, r.y, r.x + r.w + 7.0, r.y - num_buttons*k - 5.0*num_buttons, color);

      r.y -= k + 5.0;
      if button(r, "New Game") then {
        subwindow_newgame.open = true;
      }
     
      r.y -= k + 5.0;
      if button(r, "Undo (Ctrl+Z)") then {
        gui_undo_move();
      }
      r.y -= k + 5.0;
      if button(r, "Redo (Ctrl+Y)") then {
        gui_redo_move();
      }

      r.y -= k + 5.0;
      dropdown(r, string.["European Set", "Chinese Set", "Chinese Calligraphy Set"], cast(*s32)*piece_style);
      r.y -= k + 5.0;
      dropdown(r, string.["White Board", "Mocha Board", "Bamboo Board", "Rust Board", "Jade Board"], cast(*s32)*board_style);
      r.y -= k + 5.0;
      if base_checkbox(r, "Orientation", !orient) then {
        orient = !orient;
      }
      r.y -= k + 5.0;
      if base_checkbox(r, "Show Moves", show_moves) then {
        show_moves = !show_moves;
      }
      r.y -= k + 5.0;
      if base_checkbox(r, "Audio", sound) then {
        sound = !sound;
      }
      r.y -= k + 5.0;
      if base_checkbox(r, "Highlight Move", highlight_move) then {
        highlight_move = !highlight_move;
      }

      r.y -= k + 5.0;
      if base_checkbox(r, "Animations", mov_anim_state != MovAnim.Off) then {
        if mov_anim_state == MovAnim.Off
          mov_anim_state = MovAnim.Idle;
        else
          mov_anim_state = MovAnim.Off;
      }

      slider_theme := *default_overall_theme.slider_theme;
      r.y -= k + 5.0;
      slider(r, *mov_anim_complete, 0.00, 1.0, 0.01, slider_theme, suffix=" Animation");
      r.y -= k + 5.0;
    }
     
    if status_string {
      r = get_rect(5.0, 5.0, 8.5*k, k);
      label(r, status_string, label_theme);
    }

    if subwindow_newgame.open {  // The Subwindow starts open, but pressing the Close button can close it.
      add_subwindow(*subwindow_newgame);
    }

    draw_popups();  // This draws Subwindows as well.
  }

  render_xiangqiboard :: (mouse_x: float, mouse_y: float, mouse_event: bool) #expand {
    simp.clear_render_target(.15, .15, .15, 1.0);
    simp.set_shader_for_color(true);
    
    center_x: float = 0;
    center_y: float = 0;
    board_margin: float = 0;
    if off_center == true {
      center_x = height / 2.0;
      center_y = center_x;
      board_margin = center_x * .925;
    } else {
      center_x = width  / 2.0;
      center_y = height / 2.0;
      board_margin = min(center_x, center_y) * .925;
    }

    sq := board_margin / 5.0;
    hsq := sq / 2.0;
    board_x := center_x - sq * 4.5;
    board_y := center_y - sq * 5.0;
    color: Vector4 = ---;
    if board_style == {
    case .White;
      color = Vector4.{1., 1., 1., 1.};
    case .Mocha;
      color = Vector4.{.7529, .6392, .5725, 1.};
    case .Bamboo;
      color = Vector4.{.8235, .6902, .2980, 1.}; 
    case .Rust;
      color = Vector4.{.8255, .3784, .0, 1.};
    case .Jade;
      color = Vector4.{.4667, .6118, .4392, 1.};
    }
    
    simp.immediate_quad(board_x, board_y, board_x + 9.0 * sq, board_y + 10.0 * sq, color);
    board_x += hsq;
    board_y += hsq;
    
    color = Vector4.{0,0,0,1};
    // draw the board grid. 
    simp.set_shader_for_color(true);
    gridx := board_x;
    gridy := board_y;
    for 0..9 {
      line_width := 1;
      if it == 0 || it == 9 {
        line_width = 2;
      }
      simp.immediate_quad(gridx, gridy, gridx + 8*sq, gridy + line_width, color);
      gridy += sq;
    }
    
    gridx = board_x;
    gridy = board_y;
    for 0..8 {
      if it == 0 || it == 8 then {
        simp.immediate_quad(gridx, gridy, gridx + 2, gridy + 9*sq, color);
      } else {
        simp.immediate_quad(gridx, gridy, gridx + 1, gridy + 4*sq, color);
        simp.immediate_quad(gridx, gridy + 5*sq, gridx + 1, gridy + 9*sq, color);
      }
      gridx += sq;
    }
    
    gridx = board_x;
    // draw the palace diagonals.
    v0 := Vector2.{gridx + 3*sq, gridy};
    v1 := Vector2.{gridx + 5*sq, gridy + 2*sq};
    v2 := Vector2.{gridx + 5*sq - 1, gridy + 2*sq};
    v3 := Vector2.{gridx + 3*sq, gridy + 1};
    simp.immediate_quad(v0, v1, v2, v3, color);

    v0 = Vector2.{gridx + 3*sq, gridy + 2*sq};
    v1 = Vector2.{gridx + 5*sq, gridy};
    v2 = Vector2.{gridx + 5*sq + 1, gridy};
    v3 = Vector2.{gridx + 3*sq, gridy + 2*sq + 1};
    simp.immediate_quad(v0, v1, v2, v3, color);

    v0 = Vector2.{gridx + 3*sq, gridy + 7*sq};
    v1 = Vector2.{gridx + 5*sq, gridy + 9*sq};
    v2 = Vector2.{gridx + 5*sq - 1, gridy + 9*sq};
    v3 = Vector2.{gridx + 3*sq, gridy + 7*sq + 1};
    simp.immediate_quad(v0, v1, v2, v3, color);

    v0 = Vector2.{gridx + 3*sq, gridy + 9*sq};
    v1 = Vector2.{gridx + 5*sq, gridy + 7*sq};
    v2 = Vector2.{gridx + 5*sq + 1, gridy + 7*sq};
    v3 = Vector2.{gridx + 3*sq, gridy + 9*sq + 1};
    simp.immediate_quad(v0, v1, v2, v3, color);
    
    simp.set_shader_for_images(*sprites);
    {
      // Chu He Han Jie.
      sprite_x := 0;
      sprite_y := 0;
      x_river := board_x;
      y_river := board_y + sq * 4.0;
      uv0 := make_vector2(sprite_x*1.0/7.0, sprite_y*1.0/7.0);
      uv1 := make_vector2((sprite_x+2.0)*1.0/7.0, sprite_y*1.0/7.0);
      uv2 := make_vector2((sprite_x+2.0)*1.0/7.0, (sprite_y+1.0)*1.0/7.0);
      uv3 := make_vector2(sprite_x*1.0/7.0, (sprite_y+1.0)*1.0/7.0);
      immediate_quad(x_river, y_river, x_river + sq + sq, y_river + sq, color, uv0, uv1, uv2, uv3);
    }

    color = Vector4.{1., 1., 1., 1.};
    board_x -= hsq;
    board_y -= hsq;
    if show_moves == true then {
      for move: moves {
        if move.from != from_index then {
          continue;
        }
        to := move.to;
        color := Vector4.{.45, .0, .45, 0.55};
        render_possible_move(board_x, board_y, sq, to, color);
      }
    }

    if highlight_move == true then {
      if prev_from != 0xFF then {
        color := Vector4.{1.0, .55, 0.0, 0.75};
        render_possible_move(board_x, board_y, sq, prev_from, color);
      }

      if prev_to != 0xFF then {
        color := Vector4.{1.0, .55, 0.0, 0.75};
        render_possible_move(board_x, board_y, sq, prev_to, color);
      }
    }
    
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
    
    // dragged piece.
    if xiangqi_mouse == XiangqiMouse.Drag then {
      ren_idx :: float.[0.0,1.0,3.0,2.0,4.0,5.0,6.0];
      row, col := row_col_of(from_index);
      index := xiangqi.board_9x10[row][col];
      turn := (index & 2) >> 1;
      index >>= 2;
      sprite_index := ren_idx[index];
      render_piece_drag(mouse_x, mouse_y, hsq, sq, sprite_index, turn, color);
    }

    if mov_anim_state == MovAnim.Play && moves_made_count then {
      ren_idx :: float.[0.0,1.0,3.0,2.0,4.0,5.0,6.0];
      mov := moves_made[moves_made_count-1];
      from, to := orient_piece(mov.from), orient_piece(mov.to);
      piece := mov.piece >> 2;

      from_x, from_y := row_col_of(from);
      to_x, to_y := row_col_of(to);
      from_vector: Vector2; 
      from_vector.x = board_x + sq * from_x;
      from_vector.y = board_y + sq * from_y;

      to_vector: Vector2;
      to_vector.x = board_x + sq * to_x;
      to_vector.y = board_y + sq * to_y;

      ratio := mov_anim_time / mov_anim_complete;
      mov_anim_time += dt;
      if mov_anim_time >= mov_anim_complete {
        mov_anim_time = 0;
        mov_anim_state = MovAnim.Idle;
      }
      p0 := lerp(from_vector, to_vector, ratio);
      sprite_index := ren_idx[piece];
      render_piece_drag(p0.x + hsq, p0.y + hsq, hsq, sq, sprite_index, xiangqi.turn ^ 1, color);
    }
    
    simp.set_shader_for_color(true);
    for index: 0..num_arrows-1 {
      arrow: Arrow = arrows[index];
      render_arrow(arrow, board_x, board_y, sq);
    }

    render_pv_lines(red_pv_lines, board_x, board_y, sq);
    render_pv_lines(black_pv_lines, board_x, board_y, sq);

    render_pv_lines :: (pv_info: [..] PV_Info, board_x: float, board_y: float, sq: float) {
      for pv_line, identifier: pv_info {
        if pv_line.show == false then continue;
        for arrow:  pv_line.pv {
          render_arrow(arrow, board_x, board_y, sq);
        }
      }
    }

    render_arrow :: (arrow: Arrow, corner_x: float, corner_y: float, square: float) {
      hsquare := square * .5;
      from_pt := arrow_point(arrow.from, corner_x, corner_y, square, hsquare);
      to\ _pt := arrow_point(arrow.to\, corner_x, corner_y, square, hsquare);
      dx := to_pt.x - from_pt.x;
      dy := to_pt.y - from_pt.y;
      hypotenuse := sqrt(dx*dx + dy*dy);
 
      // ... I suck at trigonometry...haven't done it in a while... so this...
      ct   := (dx / hypotenuse);
      st   := (dy / hypotenuse);
      size := square * .12;
      w    := make_vector2(ct, st) * size;
      h    := make_vector2(st, -ct) * size;
 
      qsquare := square * .70;
      from_pt.x += ct * square * .425;
      from_pt.y += st * square * .425;
      to_pt.x -= ct * qsquare;
      to_pt.y -= st * qsquare;
 
      p0 := from_pt - w - h;
      p1 := to_pt + w - h;
      p2 := to_pt + w + h;
      p3 := from_pt - w + h;
      simp.immediate_quad(p0, p1, p2, p3, arrow_color);
 
      from_pt = to_pt;
      to_pt.x += ct * qsquare * .6;
      to_pt.y += st * qsquare * .6;
      w  = make_vector2(ct, st) * size;
      h  = make_vector2(st, -ct) * size;
      p0 = from_pt + w - h * 2.25;
      p1 = to_pt + w;
      p2 = from_pt + w + h * 2.25;
      simp.immediate_quad(p0, p1, p1, p2, arrow_color);
 
 
      arrow_point :: (index: int, corner_x: float, corner_y: float, square: float, half_square: float) -> Vector2 {
        index = orient_piece(cast(u8)index);
        row, col := row_col_of(cast(u8)index);
        return make_vector2(corner_x + square * row + half_square, corner_y + square * col + half_square);
      }
    }
  }

  render_right_panel :: () {
    if off_center == false {
      return;
    } 
    simp.set_shader_for_color(true);
    color := Vector4.{.1, .1, .1, .85};

    board_margin := height * ((1 - .925) *.5);
    k := clamp(height * 0.05, 35.0, 95.0);
    simp.immediate_quad(height, board_margin, width - board_margin*2.5, height - board_margin, color);
    r := get_rect(height + 3.0, height - board_margin - 3.0 - k, width - board_margin*2.5 - height - 6.0, k);
    label_r := r;
    label_r.x += k;

    hsq := k / 2.0;

    red_display_string := get_player_info(red_ai, *r_time_manager, r_time_ms);
    black_display_string := get_player_info(black_ai, *b_time_manager, b_time_ms);

    get_player_info :: (index: int, time_manager: *TimeManager, time_ms: float) -> string {
      name := "";
      if index == -1 {
        name = "";
      } else {
        name = engines_array[index].name;
      }

      if time_manager.time_control == {
      case .None;
        return name;
      case .Clock;
        time_ms /= 1000.0;
        mins := cast(int) (time_ms / 60.0);
        secs := cast(int) fmod_cycling(time_ms, 60.0);
        return tprint("%1 -- %2:%3", name, mins, formatInt(secs, minimum_digits=2));
      case .Time_per_move;
        secs_per_move := time_manager.seconds_per_move;
        return tprint("%1 -- %2 secs per move", name, formatFloat(secs_per_move, trailing_width=2));
      case .Depth;
        return tprint("%1 -- %2 Depth", name, time_manager.depth);
      }

      return "";
    } 

    bottom_string: string;
    top_string:    string;

    if orient == true {
      // red on bottom, black on top.
      bottom_string = red_display_string;
      top_string    = black_display_string;
    } else {
      // black on bottom, red on top.
      bottom_string = black_display_string; 
      top_string    = red_display_string;
    }

    color = Vector4.{1, 1, 1, 1.};
    label_theme := *default_overall_theme.label_theme;
    label(label_r, bottom_string, label_theme);


    label_r.y -= k + 5.0;
    label(label_r, top_string, label_theme);
    label_r.y -= k + 5.0;

    label_r.x -= k;
    label_r.w *= .5;

    if base_checkbox(label_r, "Red PV", show_r_eval) {
      if red_ai == -1 then
        show_r_eval = false;
      else
        show_r_eval = !show_r_eval;
    }
    label_r.x += label_r.w + 5.0;
    if base_checkbox(label_r, "Black PV", show_b_eval) {
      if black_ai == -1 then
        show_b_eval = false;
      else
        show_b_eval = !show_b_eval;
    }
    label_r.x -= label_r.w / 2.0;

    if xiangqi.turn == xx (orient) {
      color.w = .15;
    }

    simp.set_shader_for_images(*sprites);
    render_piece_drag(r.x + hsq, r.y + hsq, hsq, k, 0.0, xx !orient, color);
    color.w = 1;

    if xiangqi.turn == xx (!orient) {
      color.w = .15;
    }

    r.y -= k + 5.0;
    render_piece_drag(r.x + hsq, r.y + hsq, hsq, k, 0.0, xx orient, color);
    color.w = 1;
    region: *Scrollable_Region_State;
    inside: Rect;

    r.y -= k + 5.0;

    if red_ai != -1 && show_r_eval == true {
      // TODO: Not sure about the basic way to go about this...
      r.y -= k * 6;
      r.h =  k * 6;
      region, inside = begin_scrollable_region(r);
      s := inside;
      s.y = s.y + s.h - k;
      s.h = k;
      s.y += scroll_value_red;
      for *pv_line, identifier: red_pv_lines {

        if base_checkbox(s, show_pv_line(pv_line), pv_line.show, identifier=identifier) {
          pv_line.show = !pv_line.show;
        }
        s.y -= floor(k*1.1 + 0.5);

      }
      end_scrollable_region(region, s.x + s.w, s.y, *scroll_value_red);
      r.y -= k * .5;
    }

    if black_ai != -1 && show_b_eval == true {
      r.y -= k * 6;
      r.h =  k * 6;
      region, inside = begin_scrollable_region(r);
      s := inside;
      s.y = s.y + s.h - k;
      s.h = k;
      s.y += scroll_value_black;
      for *pv_line, identifier: black_pv_lines {
        
        if base_checkbox(s, show_pv_line(pv_line), pv_line.show, identifier=identifier) {
          pv_line.show = !pv_line.show;
        }
        s.y -= floor(k*1.1 + 0.5);

      }
      end_scrollable_region(region, s.x + s.w, s.y, *scroll_value_black);
      r.y -= k * .5;
    }

    // TODO: (DANIEL Feb 25, 2023.) I am not too sure what's the best aesthetic decision
    // about what to do here.
    show_pv_line :: (using pv_line: *PV_Info) -> string {

      builder: String_Builder;
      builder.allocator = temp;
      if eval >= 0 {
        print_to_builder(*builder, "[%.%] ", eval / 100, eval % 100);
      } else {
        score := -eval;
        print_to_builder(*builder, "[-%.%] ", score / 100, score % 100);
      }
      if depth != -1 {
        print_to_builder(*builder, "depth % | ", depth);
      }

      // engines show huge amount of nodes, so don't feel like display all the nodes...
      /*if nodes != -1 {
        print_to_builder(*builder, "nodes % | ", nodes);
      }*/

      if time != -1 {
        if time < 1000 {
          print_to_builder(*builder, "% ms | ", time);
        } else {
          // convert to seconds.
          print_to_builder(*builder, "%.% s | ", time / 1000, time % 1000);
        }
      }

      for arrow: pv {
        if arrow.from == 0 && arrow.to == 0 then break;
        move: Move32;
        move.from = arrow.from;
        move.to = arrow.to;
        append(*builder, move);
        append(*builder, " ");
      }

      return builder_to_string(*builder, temp);
    }


    val := r.y;
    r.y = board_margin + 3.0;
    r.h = val - board_margin;
    if r.h < k {
      return;  // do not render if too small...
    }
    region, inside = begin_scrollable_region(r);
    s := inside;
    s.y = s.y + s.h - k;
    s.h = k;
    s.y += move_list_scroll_value;
    // TODO: this code assumes that red goes first, which is not always the case.
    // what if we were in a custom position loaded from a fen, and black goes first?
    num_rect := s;
    num_rect.w = k;

    red_move_rect := num_rect;
    red_move_rect.x += k * 1.25;
    red_move_rect.w = s.w / 2.0;

    black_move_rect := num_rect;
    black_move_rect.x += k;
    black_move_rect.x += (s.w-2*k) / 2.0;
    black_move_rect.w = s.w / 2.0;

    // NOTE: (Daniel) Feb 25, 2023: label(r, "label", do_scissors=true) causes a compiler crash.
    index := 0;
    numbering := 0;
    while index < moves_made_count {
      numbering += 1;
      label(num_rect, tprint("%.", numbering), label_theme);

      mov_red := moves_made[index];
      label(red_move_rect, to_notation(mov_red), label_theme);
      index += 1;
      if index >= moves_made_count then
        break;

      mov_black := moves_made[index];
      index += 1;

      label(black_move_rect, to_notation(mov_black), label_theme);
      num_rect.y -= floor(k*1.1 + 0.5);
      red_move_rect.y -= floor(k*1.1 + 0.5);
      black_move_rect.y -= floor(k*1.1 + 0.5);
      s.y -= floor(k*1.1 + 0.5);

      // TODO: (DANIEL, Feb 24, 2023) this is not xiangqi standard notation. It's just UCCI moves.
      // maybe support for standard notation later?
      to_notation :: (move: Move32) -> string {
        buf := talloc_string(5);
        row_from, col_from := row_col_of(move.from);
        row_to, col_to := row_col_of(move.to);
        buf[0] = PIECE_VALUE[move.piece >> 2];
        buf[1] = (row_from + #char "a");
        buf[2] = (col_from + #char "0");
        buf[3] = (row_to + #char "a");
        buf[4] = (col_to + #char "0");
        return buf;
        // general, advisor, elephant, horse, rook, cannon, soldier
        PIECE_VALUE :: u8.[#char "K", #char "A", #char "E", #char "N", #char "R", #char "C", #char "P"]; 
      }
    }

    end_scrollable_region(region, s.x + s.w, s.y, *move_list_scroll_value);
  }

  render_piece :: (board_x: float, board_y: float, sq: float, from: u8, sprite_x: float, turn: s64, color: Vector4) {
    if xiangqi_mouse == XiangqiMouse.Drag && from == orient_piece(from_index) then {
      return;
    }
    if mov_anim_state == .Play && (from == orient_piece(prev_from) || from == orient_piece(prev_to)) then
      return;

    row, col := row_col_of(from);
    index_x := cast(float) row;
    index_y := cast(float) col;
    sprite_y := 2.0 - cast(float)turn;

    gridx := board_x + index_x*sq; 
    gridy := board_y + index_y*sq;
    if piece_style == {
    case .European;
      // do nothing.
    case .Classic;
      sprite_y += 4.0;
    case .Stylized;
      sprite_y += 2.0;
    }

    uv0 := make_vector2(sprite_x*1.0/7.0, sprite_y*1.0/7.0);
    uv1 := make_vector2((sprite_x+1.0)*1.0/7.0, sprite_y*1.0/7.0);
    uv2 := make_vector2((sprite_x+1.0)*1.0/7.0, (sprite_y+1.0)*1.0/7.0);
    uv3 := make_vector2(sprite_x*1.0/7.0, (sprite_y+1.0)*1.0/7.0);

    immediate_quad(gridx, gridy, gridx + sq, gridy + sq, color, uv0, uv1, uv2, uv3);
  }

  render_possible_move :: (board_x: float, board_y: float, sq: float, from: u8, color: Vector4) {
    row, col := row_col_of(from);
    sprite_x := 3.0;
    piece := xiangqi.board_9x10[row][col];
    if mov_anim_state != .Play && piece != 0 then
      sprite_x -= 1.0;
    sprite_y := 0.0;

    row, col = row_col_of(orient_piece(from));

    index_x := cast(float) row;
    index_y := cast(float) col;
    gridx := board_x + index_x*sq; 
    gridy := board_y + index_y*sq;

    uv0 := make_vector2(sprite_x*1.0/7.0, sprite_y*1.0/7.0);
    uv1 := make_vector2((sprite_x+1.0)*1.0/7.0, sprite_y*1.0/7.0);
    uv2 := make_vector2((sprite_x+1.0)*1.0/7.0, (sprite_y+1.0)*1.0/7.0);
    uv3 := make_vector2(sprite_x*1.0/7.0, (sprite_y+1.0)*1.0/7.0);

    // enlarge or make it smaller to make the move highlighting more aesthetically pleasing... 
    if mov_anim_state != .Play && piece != 0 then {
      immediate_quad(gridx - .05*sq, gridy - .05*sq, gridx + 1.05*sq, gridy + 1.05*sq, color, uv0, uv1, uv2, uv3);
    } else {
      immediate_quad(gridx + 0.25 * sq, gridy + 0.25 * sq, gridx + 0.75 * sq, gridy + 0.75 * sq, color, uv0, uv1, uv2, uv3);
    }
  }

  render_piece_drag :: (mousex: float, mousey: float, hsq: float, sq: float, sprite_x: float, turn: s64, color: Vector4) {

    sprite_y := 2.0 - cast(float)turn;
    if piece_style == {
    case .European;
      // do nothing.
    case .Classic;
      sprite_y += 4.0;
    case .Stylized;
      sprite_y += 2.0;
    }

    uv0 := make_vector2(sprite_x*1.0/7.0, sprite_y*1.0/7.0);
    uv1 := make_vector2((sprite_x+1.0)*1.0/7.0, sprite_y*1.0/7.0);
    uv2 := make_vector2((sprite_x+1.0)*1.0/7.0, (sprite_y+1.0)*1.0/7.0);
    uv3 := make_vector2(sprite_x*1.0/7.0, (sprite_y+1.0)*1.0/7.0);

    immediate_quad(mousex - hsq, mousey - hsq, mousex + hsq, mousey + hsq, color, uv0, uv1, uv2, uv3);

  }
}

#scope_file
width:  float = 680;
height: float = 680;
sprites: simp.Texture;
setting_sprite: simp.Texture;
piece_style: enum s32 { European; Classic; Stylized; } = .European;
board_style: enum s32 { White; Mocha; Bamboo; Rust; Jade; } = .White;
orient := false;
dt: float = 0.0;
looptime_begin: float = 0;
looptime_end: float = 0;
xiangqi: Xiangqi;
moves: Moves;
sound: bool = true;
path: string;

// mouse moves.
xiangqi_mouse := XiangqiMouse.Idle;
from_index: u8 = 0xFF;
show_moves: bool = true;
highlight_move: bool = true;
prev_from: u8 = 0xFF;
prev_to: u8 = 0xFF;

// sound player.
sound_player : *Sound_Player;
sound_quiet_move: *Mixer_Sound_Data;
sound_capture_move: *Mixer_Sound_Data;

moves_made: [256] Move32;
moves_made_count: int = 0;

// status label.
status_string: string;
move_list_scroll_value: float = 0;

// engine(s).
engines_array: [..] Engine;

init_sound :: (win: Window_Type) {
  sound_player = New(Sound_Player);
  sound_player.update_history = true;
  sound_quiet_move = load_wav_file("data/quiet_move.wav");
  assert(sound_quiet_move != null);

  sound_capture_move = load_wav_file("data/capture_move.wav");
  assert(sound_capture_move != null);

  // initialize sound player
  init(sound_player, win, true, true);

  // wav file.
  load_wav_file :: (name: string) -> *Mixer_Sound_Data {
    file_data, success := read_entire_file(name);
    assert(success);
    data := New(Mixer_Sound_Data);
    data.name = copy_string(name);
    data.buffer = file_data;

    format, samples, success2, extra := get_wav_header(data.buffer);
    if !success2 {
      log("Unable to parse '%' as wav.\n", data.full_path);
      return data;
    }

    if format.wFormatTag == WAVE_FORMAT_PCM {
      data.type = Mixer_Sound_Data.Type.LINEAR_SAMPLE_ARRAY;
      data.nchannels = cast(u16) format.nChannels;
      data.nsamples_times_nchannels = samples.count/2;
    } else if format.wFormatTag == WAVE_FORMAT_DVI_ADPCM {
      data.type = Mixer_Sound_Data.Type.ADPCM_COMPRESSED;
      data.wSamplesPerBlock = extra.wSamplesPerBlock;
      data.nBlockAlign = format.nBlockAlign;
      data.nchannels = cast(u16) format.nChannels;
      data.nsamples_times_nchannels = extra.wSamplesAccordingToFactChunk * data.nchannels;
    } else {
      assert(false);
    }

    data.samples = cast(*s16) samples.data;
    data.sampling_rate = cast(u32) format.nSamplesPerSec;
    return data;
  }
}

play_sound :: (data: *Mixer_Sound_Data, perturb: bool = true) -> *Sound_Stream {
  stream := make_stream(sound_player, data);

  if stream {
    stream.sound_data = data;
  }

  if perturb && stream {
    stream.user_volume_scale = random_get_within_range(0.9, 1.0);
    stream.desired_rate = random_get_within_range(0.85, 1.15);
  }

  if stream {
    // @Temporary @Hack! We do not get the duration by default from an ogg file...
    stream.repeat_end_position = cast(int)(data.sampling_rate * 234.475);
  }
  
  return stream;
}

immediate_quad :: (x0: float, y0: float, x1: float, y1: float, color: Vector4, uv0: Vector2, uv1: Vector2, uv2: Vector2, uv3: Vector2) {
  p0 := make_vector2(x0, y0);    
  p3 := make_vector2(x0, y1);
  p2 := make_vector2(x1, y1);
  p1 := make_vector2(x1, y0);
  simp.immediate_quad(p0, p1, p2, p3, color, uv0, uv1, uv2, uv3);
}

orient_piece :: (index: u8) -> u8 {
  if orient == true then
    return orient_index(index);
  return index;
}

gui_undo_move :: () {
  if moves_made_count <= 0 then {
    print("No moves to undo.\n");
    return;
  }

  moves_made_count -= 1;
  move := moves_made[moves_made_count];
  unmake_move(*xiangqi, move);

  reset(*moves);
  generate_moves(*xiangqi, *moves);
  filter_legal_moves(*xiangqi, *moves);

  if moves_made_count > 0 then {
    peek := moves_made_count - 1;
    last_move := moves_made[moves_made_count];
    prev_from = last_move.from;
    prev_to   = last_move.to;
  } else {
    prev_from = 0xFF;
    prev_to   = 0xFF;
  }
}

gui_redo_move :: () {
  mov := moves_made[moves_made_count];
  if mov == 0 then return;
  next := moves_made[moves_made_count+1];
  gui_make_move(mov, true);
  moves_made[moves_made_count] = next;
}

gui_make_move :: (move: Move32, animate: bool) {
  for m: moves {
    if m == move then {
      prev_from = move.from;
      prev_to   = move.to;
      make_move(*xiangqi, move);

      // add another move.
      assert (moves_made_count < moves_made.count, "Exceed the maximum allowed moves!");
      moves_made[moves_made_count] = move;
      moves_made_count += 1;

      if animate == true && mov_anim_state == MovAnim.Idle then {
        mov_anim_time = 0.0;
        mov_anim_state = MovAnim.Play;
      }

      sound_data: *Mixer_Sound_Data;
      if move.capture == 0 {
        sound_data = sound_quiet_move;
      } else {
        sound_data = sound_capture_move;
      }
      if sound == true then {
        play_sound(sound_data);
      }
      reset(*moves);
      generate_moves(*xiangqi, *moves);
      filter_legal_moves(*xiangqi, *moves);
      status_string = "";
      if moves.count == 0 then {
        status_string = "Checkmate.";  
      }
      move_list_scroll_value = 10000;
      clock_move_incr();
      break;
    }
  }
}

XiangqiMouse :: enum {
  Idle;
  Drag;
  Select;
}

Engine :: struct {
  process: Process;
  name: string;
  state: EngineState;
  timer: float;
  protocol := Protocol.uci;
}

Protocol :: enum u8 { 
  uci; 
  ucci; 
}

EngineState :: enum {
  ucciok;
  isready;
  uccinewgame;
  idle;
  go;
  bestmove;
  bug;
}

// PV = Principle Variation
PV_Info :: struct {
  show: bool = false;
  eval:  int;
  depth: int = -1;
  nodes: int = -1;
  time:  int = -1;
  pv: [16] Arrow; 
}

// TODO: I do not know whether this function is robust.
// It does not cover every possible interesting thing you
// want to know.
// This is just for getting the code off the ground
// TODO: This does not handle mate distance pruning issues.
// where a lot of info strings spit out a load of stuff...
parse_pv_info :: (line: *string) -> PV_Info, bool {
  pv_info: PV_Info;
  i := 0;
  while line.count > 0 {
    token, success := parse_token(line);
    if !success then
      break;
    if token == {
    case "string";
      // TODO: Not correct... just to handle some funny Pikafish input.
      return pv_info, false;
    case "time";
      time, success := parse_int(line);
      if success == true {
        pv_info.time = time;
      }

    case "depth";
      depth, success := parse_int(line);
      if success == true {
        pv_info.depth = depth;
      }
    case "nodes";
      nodes, success := parse_int(line);
      if success == true {
        pv_info.nodes = nodes;
      }
    case "score";
      // "score cp" is the whole token.
      {
        token, success := parse_token(line);
        if success == false then
          continue;
      }
      eval, success:= parse_int(line);
      if success == true {
        pv_info.eval = eval;
      }
    case "pv";
      while i < 16 && line.count > 0 {
        token, success := parse_token(line);
        if success == false then
          break;
        // TODO: This move sequence does not give info on pieces...
        // TODO: Parsing is NOT robust. it's just to get something to display on 
        // the screen.
        move := to_move32(*xiangqi, token);
        arrow: Arrow;
        arrow.from = move.from;
        arrow.to = move.to;
        pv_info.pv[i] = arrow;
        i += 1;
      }
    }
  }

  return pv_info, true;
}

red_pv_lines: [..] PV_Info;
black_pv_lines: [..] PV_Info;

mov_anim_time: float = 0;
mov_anim_complete: float = .12;
mov_anim_state: MovAnim = MovAnim.Idle;

MovAnim :: enum {
  Off;
  Idle;
  Play;
}

load_engine :: (name: string, protocol: Protocol) -> Engine, bool {
  #if OS == .WINDOWS {
    EXE :: ".exe";
  } else {
    EXE :: "";
  }

  engine: Engine;
  command := join(path, name, EXE);
  success := create_process(*engine.process, command, capture_and_return_output=true);
  engine.state = .ucciok;
  engine.timer = FLOAT32_INFINITY;
  engine.protocol = protocol;
  return engine, success;
}

update_ucci :: (engine: *Engine, id: int, protocol: string) {
  process := *engine.process;
  state := engine.state;
  defer engine.state = state;
  SIZE :: 4096;
  #if OS == .WINDOWS {
    NEWLINE :: "\r\n";
  } else {
    NEWLINE :: "\n";
  }

  if state == {

  case .ucciok;
    out_buff := NewArray(SIZE, u8, allocator=temp);
    err_buff: [] u8; // nothing.
    success, output_bytes := read_from_process(process, out_buff, err_buff, timeout_ms=0);
    messages: string;
    messages.data = out_buff.data;
    messages.count = output_bytes;

    ok := tprint("%1ok", protocol);
    for msg, index: split(messages, NEWLINE) {
      message := msg;
      if message then
        print("%\n", message);

      // either ucciok or uciok
      if equal(message, ok) then {
        state = .isready;
        engine.timer = FLOAT32_INFINITY;
      } 
    }

  case .isready;
    out_buff := NewArray(SIZE, u8, allocator=temp);
    err_buff: [] u8; // nothing.
    success, output_bytes := read_from_process(process, out_buff, err_buff, timeout_ms=0);
    messages: string;
    messages.data = out_buff.data;
    messages.count = output_bytes;
    for msg, index: split(messages, NEWLINE) {
      message := msg;
      if message then
        print("%\n", message);
      if equal(message, "readyok") then {
        state = .uccinewgame;
        engine.timer = FLOAT32_INFINITY;
      } 
    }
  case .uccinewgame;
    state = .idle;
  case .idle;
    if is_engine_turn(id) then {
      state = .go;
      engine.timer = 0.0;
    }
  case .go;
    if xiangqi.turn == 0 {
      red_pv_lines.count = 0;
    } else {
      black_pv_lines.count = 0;
    }
    state = .bestmove;
  case .bestmove;
    if !is_engine_turn(id) then {
      state = .idle;
      engine.timer = FLOAT32_INFINITY;
    } else {
      out_buff := NewArray(SIZE, u8, allocator=temp);
      err_buff: [] u8; // nothing.
      success, output_bytes := read_from_process(process, out_buff, err_buff, timeout_ms=0);
      messages: string;
      messages.data = out_buff.data;
      messages.count = output_bytes;
      for msg, index: split(messages, NEWLINE) {
        message := msg;
        if message {
          print("%\n", message);
        }
        if starts_with(message, "info ") then {
          parse_token(*message);
          message = eat_spaces(message);
          pv_info, success := parse_pv_info(*message);
          if success == false then
            continue;

          // limit the number of PV lines to 100 
          if xiangqi.turn == 0 {
            if red_pv_lines.count <= 100 then {
              array_add(*red_pv_lines, pv_info);
              scroll_value_red = 10000;
            }
          } else {
            if black_pv_lines.count <= 100 then {
              array_add(*black_pv_lines, pv_info);
              scroll_value_black = 10000;
            }
          }
        }

        if starts_with(message, "bestmove ") then {
          parse_token(*message);
          message = eat_spaces(message);
          mov_token := parse_token(*message);
          mov := to_move32(*xiangqi, mov_token);
          gui_make_move(mov, true);
          state = .idle;
        }
      }
    }
  }

  engine.timer += dt;

  // write.
  if state == {
  case .ucciok;
    if engine.timer > 3.0 then {
      write_to_process(process, to_u8_array(tprint("%1%2", protocol, NEWLINE)));
      engine.timer = 0.0;
    } 
  case .isready;
    if engine.timer > 5.0 then {
      write_to_process(process, to_u8_array("isready\n"));
      engine.timer = 0.0;
    } 
  case .uccinewgame;
    if engine.timer > 5.0 then {
      write_to_process(process, to_u8_array(tprint("%1newgame%2", protocol, NEWLINE)));
      engine.timer = 0.0;
    }
  case .idle;
    engine.timer = FLOAT32_INFINITY;
  case .go;
    str := get_ucci_position();
    timeManager := ifx xiangqi.turn == 0 r_time_manager else b_time_manager;
    write_to_process(process, to_u8_array(str));
    sleep_milliseconds(10); // TODO: bad hack...

    gostr := ucci_go_command(engine, timeManager);
    print("%\n", gostr);
    write_to_process(process, to_u8_array(gostr));

  case .bestmove;
    // waiting to get the best move.
    // don't do anything.
  case .bug;

  }

  ucci_go_command :: (engine: *Engine, using timeManager: TimeManager) -> string {
    if #complete time_control == {
    case .None;
      return tprint("go depth 5%1", NEWLINE);

    case .Clock;
      // time in milliseconds
      if engine.protocol == .uci {
        return tprint("go wtime %1 btime %2 winc %3 binc %4%5", 
                      cast(int) r_time_ms, 
                      cast(int) b_time_ms, 
                      cast(int) r_time_manager.increment_ms, 
                      cast(int) b_time_manager.increment_ms,
                      NEWLINE);
      } else {
        time: int;
        opptime: int;
        increment: int;
        oppincrement: int;
        ifx xiangqi.turn == 0 {

          time = cast(int) r_time_ms;
          increment = cast(int) r_time_manager.increment_ms;

          opptime = cast(int) b_time_ms;
          oppincrement = cast(int) b_time_manager.increment_ms;

        } else {

          time = cast(int) b_time_ms;
          increment = cast(int) b_time_manager.increment_ms;

          opptime = cast(int) r_time_ms;
          oppincrement = cast(int) r_time_manager.increment_ms;

        }
        return tprint("go time %1 increment %2 opptime %3 oppincrement %4%5",
               time,
               increment,
               opptime,
               oppincrement,
               NEWLINE);
      }

    case .Time_per_move;
      ms := cast(int)(timeManager.seconds_per_move * 1000.0);
      if engine.protocol == .uci {
        // time in milliseconds
        return tprint("go movetime %1%2", ms, NEWLINE);
      } else {
        // TODO: (DANIEL Feb 26, 2023) best I can do given I don't know what is the correct command for
        // "Think for x time per move..."
        return tprint("go time %1%2", ms, NEWLINE);
      }

    case .Depth;
      return tprint("go depth %1%2", timeManager.depth, NEWLINE);
    }
  }


}

fen_string := "";

get_ucci_position :: () -> string {
  #if OS == .WINDOWS {
    NEWLINE :: "\r\n";
  } else {
    NEWLINE :: "\n";
  }

  builder: String_Builder;
  builder.allocator = temp;
  if fen_string then
    print_to_builder(*builder, "position fen %", fen_string);
  else
    append(*builder, "position startpos");
  if moves_made_count > 0
    append(*builder, " moves");
  for index: 0..moves_made_count-1 {
    move := moves_made[index];
    append(*builder, " ");
    append(*builder, move);
  }
  append(*builder, NEWLINE);
  return builder_to_string(*builder, allocator=temp);
}

to_u8_array :: (str: string) -> [] u8 {
  array: [] u8;
  array.data = str.data;
  array.count = str.count;
  return array;
}

arrows: [128] Arrow;
arrow_index: int = 0;
num_arrows: int = 0;
arrow_color :: Vector4.{.15, .15, .15, .75};
xiangqi_highlight := XiangqiMouse.Idle;
xiangqi_highlight_select := -1;

off_center: bool = false;
SQRT2 :: 1.41421356237; // the square root of 2. used for a "golden section"

Arrow :: struct {
  from: u8;
  to: u8;
}

add_arrow :: (arrow: Arrow) {
  arrows[arrow_index] = arrow;
  arrow_index += 1;
  arrow_index %= arrows.count;
  num_arrows += 1;
  num_arrows = min(num_arrows, cast(int)arrows.count);
}

clear_arrows :: () #expand {
  arrow_index = 0;
  num_arrows = 0;
}

display_settings := false;

red_ai: int = -1;
black_ai: int = -1;

// subwindow new game.
subwindow_newgame: Subwindow_Info;

is_engine_turn :: (index: int) -> bool {
  if xiangqi.turn == 0 && red_ai == index then
    return true;
  if xiangqi.turn == 1 && black_ai == index then
    return true;
  return false;
}

close_engine :: (engine: *Engine) {
  // send a "quit" command before closing the chess engine.
  process := *engine.process;
  quit := "quit\n";
  write_buffer: [] u8;
  write_buffer.data = quit.data;
  write_buffer.count = quit.count;
  print("shutdown engine\n");
  write_to_process(process, write_buffer);
  deinit(process);
  kill_process(process);
}

overall_theme_modify :: () {
  button_theme := *default_overall_theme.button_theme;
  button_theme.alignment = .Left;

  checkbox_theme := *default_overall_theme.checkbox_theme;
  checkbox_theme.alignment = .Left;

  scrollable_region_theme := *default_overall_theme.scrollable_region_theme;
  scrollable_region_theme.region_background.shape.roundedness = .02;

  label_theme := *default_overall_theme.label_theme;
  label_theme.alignment = .Left;

  dropdown_theme := *default_overall_theme.dropdown_theme;
  dropdown_theme.theme_for_current_value.alignment = .Left;
  dropdown_theme.theme_for_each_choice.alignment = .Left;
  dropdown_theme.theme_for_current_choice.alignment = .Left;
}

ui_set_font :: (font: *simp.Dynamic_Font) {
  // set dropdown theme font
  dropdown_theme := *default_overall_theme.dropdown_theme;
  dropdown_theme.theme_for_current_value.font = font;
  dropdown_theme.theme_for_each_choice.font = font;
  dropdown_theme.theme_for_current_choice.font = font;

  // set button theme font
  button_theme := *default_overall_theme.button_theme;
  button_theme.font = font;

  // set label theme font
  label_theme := *default_overall_theme.label_theme;
  label_theme.font = font;

  // set checkbox theme font
  checkbox_theme := *default_overall_theme.checkbox_theme;
  checkbox_theme.font = font;

  // color picker theme in "GetRect" not supported. however,
  // for our use case, is pointless.

  // subwindow theme font
  subwindow_theme := *default_overall_theme.subwindow_theme;
  subwindow_theme.title_bar.font = font;
  subwindow_theme.close_button.font = font;

  // scrollable region
  // I do not think scrollable region needs a font. 
  // since it is just for scrolling

  // slidable region
  // I do not think slidable region needs a font. 
  // since it is just for sliding

  // slider theme font
  slider_theme := *default_overall_theme.slider_theme;
  slider_theme.foreground.font = font;
  slider_theme.background.font = font;
  slider_theme.text_input_theme.font = font;
  slider_theme.spinbox_theme.font = font;

  // text input theme
  text_input_theme := *default_overall_theme.text_input_theme;
  text_input_theme.font = font;
}

load_engines_at_startup :: () {
  e, success := load_engine("pikafish", .uci);
  if success == true {
    e.name = "Pikafish";
    print("Loading engine: %\n", e.name);
    array_add(*engines_array, e);
  }
  e, success = load_engine("eleeye", .ucci);
  if success == true {
    e.name = "Elephant Eye";
    print("Loading engine: %\n", e.name);
    array_add(*engines_array, e);
  }
}

newgame_w_choice: s32 = 0;
newgame_b_choice: s32 = 0;
subwindow_fenstring := "startpos";

draw_subwindow_newgame :: (r: Rect, data: *void) {
  // themes
  slider_theme := *default_overall_theme.slider_theme;
  label_theme := *default_overall_theme.label_theme;
  text_theme: *Text_Input_Theme = *default_overall_theme.text_input_theme;


  display_settings = false;
  k := clamp(height * 0.05, 15.0, 45.0);
  arr := get_engine_names();
  rect := get_rect(r.x + 3, r.y + r.h - k - 3, r.w - k*2.5 - 9, k);
  label(rect, "Fen", label_theme);
  rect.x += k * 2.5;
  action_c, _, fen_state := text_input(rect, subwindow_fenstring, text_theme);
  if action_c & .TEXT_MODIFIED {
    subwindow_fenstring = get_result(fen_state);
  }
  rect.y -= k * 1.1;
  rect.x -= k * 2.5;
  label(rect, "Red", label_theme);
  rect.x += k * 2.5;
  dropdown(rect, arr, *newgame_w_choice);
  rect.x -= k * 2.5;
  rect.y -= k * 1.1;
  label(rect, "Black", label_theme);
  rect.x += k * 2.5;
  dropdown(rect, arr, *newgame_b_choice);
  rect.y -= k * 1.1;
  if base_checkbox(rect, "Equal Time Control", equal_time_control) {
    equal_time_control = !equal_time_control;
  }

  rect.x -= k * 2.5;
  rect.y -= k * 1.1;

  time_management_ui(*rect, ifx equal_time_control then "Time" else "Red", *r_time_manager, k, 0);
  if equal_time_control == false {
    time_management_ui(*rect, "Black", *b_time_manager, k, 3);
  } else {
    b_time_manager = r_time_manager;
  }

  rect.x += k * 2.5;
  if button(rect, "Play") {
    subwindow_newgame.open = false;
    str := get_result(fen_state);
    if !str || equal(str, "startpos") then {
      xiangqi_startpos(*xiangqi);
      fen_string = "";
    } else {
      if xiangqi_fen(*xiangqi, str) {
        fen_string = copy_string(str);
      } else {
        xiangqi_startpos(*xiangqi);
        fen_string = "";
      }
    }
    set_input(fen_state, "startpos"); 
    subwindow_fenstring = "startpos";
    status_string = "";
    xiangqi_startpos(*xiangqi);
    moves_made_count = 0;
    reset(*moves);
    memset(*moves_made, 0, size_of(type_of(moves_made)));
    generate_moves(*xiangqi, *moves);
    filter_legal_moves(*xiangqi, *moves);
    prev_from = 0xFF;
    prev_to   = 0xFF;
    red_ai = newgame_w_choice - 1;
    black_ai = newgame_b_choice - 1;
    r_time_ms = r_time_manager.clock_ms;
    b_time_ms = b_time_manager.clock_ms;
  }

  get_engine_names :: () -> [..] string {
    arr: [..] string;
    arr.allocator = temp;
    array_add(*arr, "(none)");
    for engine: engines_array {
      array_add(*arr, engine.name);
    }
    return arr;
  }

  TimeCtrl :: string.["None", "Clock", "Time Per Move", "Depth"];

  time_management_ui :: (rect: *Rect, name: string, time_manager: *TimeManager, k: float, id: int) {
    slider_theme := *default_overall_theme.slider_theme;
    label_theme := *default_overall_theme.label_theme;
    text_theme: *Text_Input_Theme = *default_overall_theme.text_input_theme;
    label(rect, name, label_theme);
    rect.x += k * 2.5;
    dropdown(rect, TimeCtrl, cast(*s32)*time_manager.time_control, identifier=id);
    rect.y -= k * 1.1;
    if time_manager.time_control == {
    case .Clock;
      function := slider_theme.format_text_float;
      slider_theme.format_text_float = format_float_time_clk;
      slider(rect, *time_manager.clock_ms, 1000, 1000 * 59 * 60, 1000, slider_theme, identifier=id+1);
      rect.y -= k * 1.1;
      slider_theme.format_text_float = format_float_incr_clk;
      slider(rect, *time_manager.increment_ms, 0, 1000*30, 10, slider_theme, identifier=id+2);
      rect.y -= k * 1.1;
      slider_theme.format_text_float = function;
    case .Time_per_move;
      slider_theme := *default_overall_theme.slider_theme;
      slider(rect, *time_manager.seconds_per_move, 0.01, 10.0, 0.01, slider_theme, suffix=" seconds per move", identifier=id+1);
      rect.y -= k * 1.1;
    case .Depth;
      slider(rect, *time_manager.depth, 1, 50, 1, slider_theme, prefix="Depth ", identifier=id+1);
      rect.y -= k * 1.1;
    }
    rect.x -= k * 2.5;
  }

}

format_float_time_clk :: (prefix: string, suffix: string, value: float64, theme: *Slider_Theme, state: *Slider_State, mode: Slider_Format_Text_Mode) -> string {
   value /= 1000.0;
   mins := cast(int) (value / 60.0);
   secs := cast(int) fmod_cycling(cast(float)value, 60.0);
   return tprint("%1:%2", mins, formatInt(secs, minimum_digits=2));
}

format_float_incr_clk :: (prefix: string, suffix: string, value: float64, theme: *Slider_Theme, state: *Slider_State, mode: Slider_Format_Text_Mode) -> string {
   value /= 1000.0;
   return tprint("%1 seconds increment", formatFloat(value, trailing_width=2));
}

equal_time_control := true;
show_r_eval: bool = false;
show_b_eval: bool = false;

scroll_value_red: float;
scroll_value_black: float;


TimeControl :: enum s8 {
  None;
  Clock;
  Time_per_move;
  Depth;
}

TimeManager :: struct {
  time_control: TimeControl;
  clock_ms: float = 1000 * 5 * 60;
  increment_ms: float = 1000;
  depth: int = 1;
  seconds_per_move: float = 2.0;
}

r_time_manager: TimeManager;
b_time_manager: TimeManager;

r_time_ms: float;
b_time_ms: float;

clock_update :: () {

  if xiangqi.turn == 0 {
    if r_time_manager.time_control == .Clock {
      r_time_ms -= dt * 1000;
      r_time_ms = max(0.0, r_time_ms);
    }
  } else {
    if b_time_manager.time_control == .Clock {
      b_time_ms -= dt * 1000;
      b_time_ms = max(0.0, b_time_ms);
    }
  }

}

clock_move_incr :: () {

  if xiangqi.turn == 0 {
    if r_time_manager.time_control == .Clock {
      r_time_ms += r_time_manager.increment_ms;
    }
  } else {
    if b_time_manager.time_control == .Clock {
      b_time_ms += b_time_manager.increment_ms;
    }
  }

}

#import "Window_Creation";
#import "System";
#import "Basic";
simp :: #import "Simp";
#import "Input";
#import "Math";
#import "GetRect";
#import "Sound_Player";
#import "Wav_File";
#import "File";
#import "Random";
#import "Process";
#load "movegen.jai";
