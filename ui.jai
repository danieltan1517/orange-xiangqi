main :: () {
  init_xiangqi_tables();
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
    if off_center == true && right_panel_display != 2 {
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
            
            sq := row_col_to_index(row, col);
            piece := xiangqi.board[sq];
            if piece != 0 then {
              xiangqi_mouse = XiangqiMouse.Drag;
              from_index = cast(u8) row_col_to_index(row, col);
            }
          }
       
        case XiangqiMouse.Drag;
          to_index := row_col_to_index(row, col);
          if from_index != to_index then {
            piece := xiangqi.board[from_index];
            capture := xiangqi.board[row + col * 9];
            move := Move32.{cast(u8)from_index, cast(u8)to_index, capture, piece};
            gui_make_move(move, false);
            xiangqi_mouse = XiangqiMouse.Idle;
            from_index = 0xFF;
          } else {
            xiangqi_mouse = XiangqiMouse.Select;
          }
       
        case XiangqiMouse.Select;
          to_index := row_col_to_index(row, col);
          piece := xiangqi.board[from_index];
          capture := xiangqi.board[row + col * 9];
          move := Move32.{cast(u8)from_index, cast(u8)to_index, capture, piece};
          gui_make_move(move, true);
          xiangqi_mouse = XiangqiMouse.Idle;
          from_index = 0xFF;
        }
      } else {
        position := row_col_to_index(row, col);
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
    k := clamp(height * 0.05, 15.0, 45.0);
    r := get_rect(5.0, height - 2.5 - k, k, k);

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

      num_buttons :: 15.0;
      simp.immediate_quad(17.0, r.y, r.x + r.w + 7.0, r.y - num_buttons*k - 5.0*num_buttons - 3.0, color);

      r.y -= k + 5.0;
      if button(r, get_ui_str().new_game) then {
        subwindow_newgame.open = true;
      }

      r.y -= k + 5.0;
      dropdown(r, get_ui_str().right_panel, *right_panel_display);
     
      r.y -= k + 5.0;
      if button(r, get_ui_str().undo) then {
        gui_undo_move();
      }
      r.y -= k + 5.0;
      if button(r, get_ui_str().redo) then {
        gui_redo_move();
      }

      r.y -= k + 5.0;
      dropdown(r, get_ui_str().piece_style, cast(*s32)*piece_style);
      r.y -= k + 5.0;
      dropdown(r, get_ui_str().board_style, cast(*s32)*board_style);
      r.y -= k + 5.0;
      if base_checkbox(r, get_ui_str().orientation, !orient) then {
        orient = !orient;
      }

      r.y -= k + 5.0;
      if base_checkbox(r, get_ui_str().blindfold, blindfold) then {
        blindfold = !blindfold;
      }

      r.y -= k + 5.0;
      if base_checkbox(r, get_ui_str().show_moves, show_moves) then {
        show_moves = !show_moves;
      }
      r.y -= k + 5.0;
      if base_checkbox(r, get_ui_str().audio, sound) then {
        sound = !sound;
      }
      r.y -= k + 5.0;
      if base_checkbox(r, get_ui_str().highlight_move, highlight_move) then {
        highlight_move = !highlight_move;
      }

      r.y -= k + 5.0;
      if base_checkbox(r, get_ui_str().animations, mov_anim_state != MovAnim.Off) then {
        if mov_anim_state == MovAnim.Off
          mov_anim_state = MovAnim.Idle;
        else
          mov_anim_state = MovAnim.Off;
      }

      slider_theme := *default_overall_theme.slider_theme;
      r.y -= k + 5.0;
      slider(r, *mov_anim_complete, 0.00, 1.0, 0.01, slider_theme, prefix=get_ui_str().animation_speed);
      r.y -= k + 5.0;

      if base_checkbox(r, get_ui_str().logging, engine_logging) {
        engine_logging = !engine_logging;
      }      
      r.y -= k + 5.0;

      dropdown(r, string.["English", "简体中文"], cast(*s32)*language);
      r.y -= k + 5.0;
    }
     
    if status_string {
      r = get_rect(5.0, 5.0, 15*k, k);
      label(r, status_string, label_theme);
    }
  }

  render_xiangqiboard :: (mouse_x: float, mouse_y: float, mouse_event: bool) #expand {
    simp.set_shader_for_color(true);
    
    center_x: float = 0;
    center_y: float = 0;
    board_margin: float = 0;
    if off_center == true && right_panel_display != 2 {
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
      color = Vector4.{.999, .958, .859, 1.};
    case .Mocha;
      color = Vector4.{.707, .605, .484, 1.};
    case .Bamboo;
      color = Vector4.{.824, .6875, .00703, 1.}; 
    case .Rust;
      color = Vector4.{.7456, .35764, .0, 1.};
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

    right_crosses :: (x: float, y: float, gridx: float, gridy: float, sq: float, color: Vector4) {
      v0, v1, v2, v3: Vector2;
      v0 = Vector2.{gridx + (x + 0.250)*sq, gridy + (y - 0.050)*sq - 1};
      v1 = Vector2.{gridx + (x + 0.050)*sq, gridy + (y - 0.050)*sq - 1};
      v2 = Vector2.{gridx + (x + 0.050)*sq, gridy + (y - 0.050)*sq};
      v3 = Vector2.{gridx + (x + 0.250)*sq, gridy + (y - 0.050)*sq};
      simp.immediate_quad(v0, v1, v2, v3, color);
     
      v0 = Vector2.{gridx + (x + 0.050)*sq+1, gridy + (y - 0.050)*sq};
      v1 = Vector2.{gridx + (x + 0.050)*sq+1, gridy + (y - 0.250)*sq}; 
      v2 = Vector2.{gridx + (x + 0.050)*sq,   gridy + (y - 0.250)*sq};
      v3 = Vector2.{gridx + (x + 0.050)*sq,   gridy + (y - 0.050)*sq};
      simp.immediate_quad(v0, v1, v2, v3, color);
     
      v0 = Vector2.{gridx + (x + 0.250)*sq, gridy + (y + 0.050)*sq + 1};
      v1 = Vector2.{gridx + (x + 0.250)*sq, gridy + (y + 0.050)*sq};
      v2 = Vector2.{gridx + (x + 0.050)*sq, gridy + (y + 0.050)*sq};
      v3 = Vector2.{gridx + (x + 0.050)*sq, gridy + (y + 0.050)*sq + 1};
      simp.immediate_quad(v0, v1, v2, v3, color);
     
      v0 = Vector2.{gridx + (x + 0.050)*sq + 1, gridy + (y + 0.050)*sq};
      v1 = Vector2.{gridx + (x + 0.050)*sq,     gridy + (y + 0.050)*sq};
      v2 = Vector2.{gridx + (x + 0.050)*sq,     gridy + (y + 0.250)*sq};
      v3 = Vector2.{gridx + (x + 0.050)*sq + 1, gridy + (y + 0.250)*sq};
      simp.immediate_quad(v0, v1, v2, v3, color);
    }  

    left_crosses :: (x: float, y: float, gridx: float, gridy: float, sq: float, color: Vector4) {
      v0, v1, v2, v3: Vector2;
      v0 = Vector2.{gridx + (x - 0.050)*sq+1, gridy + (y - 0.050)*sq};
      v1 = Vector2.{gridx + (x - 0.050)*sq+1, gridy + (y - 0.250)*sq};
      v2 = Vector2.{gridx + (x - 0.050)*sq,   gridy + (y - 0.250)*sq};
      v3 = Vector2.{gridx + (x - 0.050)*sq,   gridy + (y - 0.050)*sq};
      simp.immediate_quad(v0, v1, v2, v3, color);
     
      v0 = Vector2.{gridx + (x - 0.250)*sq, gridy + (y - 0.050)*sq - 1};
      v1 = Vector2.{gridx + (x - 0.250)*sq, gridy + (y - 0.050)*sq};
      v2 = Vector2.{gridx + (x - 0.050)*sq, gridy + (y - 0.050)*sq};
      v3 = Vector2.{gridx + (x - 0.050)*sq, gridy + (y - 0.050)*sq - 1};
      simp.immediate_quad(v0, v1, v2, v3, color);
     
      // other one....
      v0 = Vector2.{gridx + (x - 0.250)*sq, gridy + (y + 0.050)*sq + 1};
      v1 = Vector2.{gridx + (x - 0.250)*sq, gridy + (y + 0.050)*sq};
      v2 = Vector2.{gridx + (x - 0.050)*sq, gridy + (y + 0.050)*sq};
      v3 = Vector2.{gridx + (x - 0.050)*sq, gridy + (y + 0.050)*sq + 1};
      simp.immediate_quad(v0, v1, v2, v3, color);
     
      v0 = Vector2.{gridx + (x - 0.050)*sq + 1, gridy + (y + 0.050)*sq};
      v1 = Vector2.{gridx + (x - 0.050)*sq,     gridy + (y + 0.050)*sq};
      v2 = Vector2.{gridx + (x - 0.050)*sq,     gridy + (y + 0.250)*sq};
      v3 = Vector2.{gridx + (x - 0.050)*sq + 1, gridy + (y + 0.250)*sq};
      simp.immediate_quad(v0, v1, v2, v3, color);
    }

    crosses :: (x: float, y: float, gridx: float, gridy: float, sq: float, color: Vector4) {
      left_crosses(x, y, gridx, gridy, sq, color);
      right_crosses(x, y, gridx, gridy, sq, color);
    }

    pawn_crosses :: (y: float, gridx: float, gridy: float, sq: float, color: Vector4) {
      right_crosses(0,y, gridx, gridy, sq, color);
      crosses (2,y, gridx, gridy, sq, color);
      crosses (4,y, gridx, gridy, sq, color);
      crosses (6,y, gridx, gridy, sq, color);
      left_crosses (8,y, gridx, gridy, sq, color);
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

    crosses(1,2, gridx, gridy, sq, color);
    crosses(7,2, gridx, gridy, sq, color);

    crosses(1,7, gridx, gridy, sq, color);
    crosses(7,7, gridx, gridy, sq, color);

    pawn_crosses(3, gridx, gridy, sq, color);
    pawn_crosses(6, gridx, gridy, sq, color);

    simp.set_shader_for_images(*sprites);
    color = Vector4.{1., 1., 1., 1.};
    board_x -= hsq;
    board_y -= hsq;
    if show_moves == true then {
      for move: moves {
        
        if move.from != from_index then {
          continue;
        }
        to := move.to;
        render_possible_move(board_x, board_y, sq, to, arrow_color);
      }
    }
    
    if highlight_move == true then {
      if prev_from != 0xFF then {
        render_possible_move(board_x, board_y, sq, prev_from, arrow_color);
      }

      if prev_to != 0xFF then {
        render_possible_move(board_x, board_y, sq, prev_to, arrow_color);
      }
    }
    
    // draw all the pieces.
    if blindfold == false {
      for piece_array, turn: xiangqi.pieces {
        gen := piece_array.king.array[0];
        gen = orient_piece(gen);
        render_piece(board_x, board_y, sq, gen, 0.0, turn, color);
     
        for adv: piece_array.adv {
          adv = orient_piece(adv);
          render_piece(board_x, board_y, sq, adv, 1.0, turn, color);
        }
     
        for ele: piece_array.ele {
          ele = orient_piece(ele);
          render_piece(board_x, board_y, sq, ele, 3.0, turn, color);
        }
     
        for kni: piece_array.kni {
          kni = orient_piece(kni);
          render_piece(board_x, board_y, sq, kni, 2.0, turn, color);
        }
     
        for rook: piece_array.rook {
          rook = orient_piece(rook);
          render_piece(board_x, board_y, sq, rook, 4.0, turn, color);
        }
     
        for can: piece_array.cannon {
          can = orient_piece(can);
          render_piece(board_x, board_y, sq, can, 5.0, turn, color);
        }
     
        for sol: piece_array.pawn {
          sol = orient_piece(sol);
          render_piece(board_x, board_y, sq, sol, 6.0, turn, color);
        }
      }
    
      // dragged piece.
      if xiangqi_mouse == XiangqiMouse.Drag then {
        ren_idx :: float.[0.0,1.0,3.0,2.0,4.0,5.0,6.0];
        row, col := row_col_of(from_index);
        index := xiangqi.board[row + col * 9];
        turn := (index & 2) >> 1;
        index >>= 2;
        sprite_index := ren_idx[index];
        render_piece_drag(mouse_x, mouse_y, hsq, sq, sprite_index, turn, color);
      }
     
      if mov_anim_state == MovAnim.Play && moves_made_count then {
        ren_idx :: float.[0.0,1.0,3.0,2.0,4.0,5.0,6.0];
        mov := xiangqi.hashes.info[moves_made_count-1].move;
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

    }
    
    simp.set_shader_for_color(true);
    for index: 0..num_arrows-1 {
      arrow: Arrow = arrows[index];
      render_arrow(arrow, board_x, board_y, sq);
    }
      
    if highlight_move == true then {
      arrow: Arrow;
      arrow.from = cast(u8) prev_from;
      arrow.to   = cast(u8) prev_to;
      render_arrow(arrow, board_x, board_y, sq);
    }

    render_pv_lines :: (pv_info: [..] PV_Info, board_x: float, board_y: float, sq: float) {
      for pv_line, identifier: pv_info {
        if pv_line.show == false then continue;
        for arrow:  pv_line.pv {
          render_arrow(arrow, board_x, board_y, sq);
        }
      }
    }

    render_pv_lines(red_pv_lines, board_x, board_y, sq);
    render_pv_lines(black_pv_lines, board_x, board_y, sq);
  }

  display_moves :: (height: float, board_margin: float, width: float, k: float) #expand {
    r := get_rect(height + 3.0, height - board_margin - 3.0 - k, width - board_margin*2.5 - height - 6.0, k);
    label_r := r;
    label_r.x += k;

    hsq := k / 2.0;
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
        if index == -1 then {
          return name;
        }

        secs_per_move := time_manager.seconds_per_move;
        return tprint("%1 -- %2 secs per move", name, formatFloat(secs_per_move, trailing_width=2));
      case .Depth;
        if index == -1 then {
          return name;
        }

        return tprint("%1 -- Depth %2", name, time_manager.depth);
      }

      return "";
    } 

    red_display_string := get_player_info(red_ai, *r_time_manager, r_time_ms);
    black_display_string := get_player_info(black_ai, *b_time_manager, b_time_ms);

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

    color := Vector4.{1, 1, 1, 1.};
    label_theme := *default_overall_theme.label_theme;
    label(label_r, bottom_string, label_theme);


    label_r.y -= k + 5.0;
    label(label_r, top_string, label_theme);
    label_r.y -= k + 5.0;

    label_r.x -= k;
    label_r.w *= .5;

    if base_checkbox(label_r, get_ui_str().red_pv, show_r_eval) {
      if red_ai == -1 then
        show_r_eval = false;
      else
        show_r_eval = !show_r_eval;
    }
    label_r.x += label_r.w + 5.0;
    if base_checkbox(label_r, get_ui_str().black_pv, show_b_eval) {
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

    // TODO: (DANIEL, Feb 24, 2023) this is not xiangqi standard notation. It's just UCCI moves.
    // maybe support for standard notation later?
    to_notation :: (move: Move32) -> string {
      PIECE_VALUE :: u8.[#char "K", #char "A", #char "E", #char "N", #char "R", #char "C", #char "P"]; 
      buf := talloc_string(5);
      row_from, col_from := row_col_of(move.from);
      row_to, col_to := row_col_of(move.to);
      buf[0] = PIECE_VALUE[move.piece >> 2];
      buf[1] = cast(u8)(row_from + #char "a");
      buf[2] = xx (col_from + #char "0");
      buf[3] = xx (row_to + #char "a");
      buf[4] = xx (col_to + #char "0");
      return buf;
      // general, advisor, elephant, horse, rook, cannon, soldier
    }

    // NOTE: (Daniel) Feb 25, 2023: label(r, "label", do_scissors=true) causes a compiler crash.
    index := 0;
    numbering := 0;
    while index < moves_made_count {
      numbering += 1;
      label(num_rect, tprint("%.", numbering), label_theme);

      mov_red := xiangqi.hashes.info[index].move;
      label(red_move_rect, to_notation(mov_red), label_theme);
      index += 1;
      if index >= moves_made_count then
        break;

      mov_black := xiangqi.hashes.info[index].move;
      index += 1;

      label(black_move_rect, to_notation(mov_black), label_theme);
      num_rect.y -= floor(k*1.1 + 0.5);
      red_move_rect.y -= floor(k*1.1 + 0.5);
      black_move_rect.y -= floor(k*1.1 + 0.5);
      s.y -= floor(k*1.1 + 0.5);
    }

    end_scrollable_region(region, s.x + s.w, s.y, *move_list_scroll_value);
  }

  render_right_panel :: () {
    if off_center == false || right_panel_display == 2 {
      return;
    } 
    simp.set_shader_for_color(true);
    color := Vector4.{.1, .1, .1, .85};

    board_margin := height * ((1 - .925) *.5);
    k := clamp(height * 0.05, 35.0, 95.0);
    simp.immediate_quad(height, board_margin, width - board_margin*2.5, height - board_margin, color);

    if right_panel_display == 0 {
      display_moves(height, board_margin, width, k);
    } else if right_panel_display == 1 {
      engines_panel(height, board_margin, width, k);
    }
  }

  // init_zobrist_tables(); todo: add back in later...
  random_seed(current_time_monotonic().low);

  path = copy_string(path_strip_filename(get_path_of_running_executable()));
  set_working_directory(path);
  set_default_theme(default_theme_procs[Default_Themes.Grayscale]());
  overall_theme_modify();
  win := create_window(cast(int) width, cast(int) height, "Xiangqi");
  simp.set_render_target(win);
  font := simp.get_font_at_size("data", "SourceHanSansHWSC-Regular.otf", 16);
  ui_set_font(font);

  xiangqi_startpos(*xiangqi);
  reset(*moves);
  array_reserve(*red_pv_lines, 200);
  array_reserve(*black_pv_lines, 200);
  legal_moves(*xiangqi, *moves);
  init_sound();
  init_textures();
  ui_init();
  ctrl_pressed := 0;

  load_engines_at_startup();

  subwindow_newgame.rect = get_rect(50,50,580,580);
  subwindow_newgame.draw = draw_subwindow_newgame;
  subwindow_newgame.title_text = get_ui_str().new_game;
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

    simp.clear_render_target(.15, .15, .15, 1.0);
    render_xiangqiboard(cast(float)mouse_x, cast(float)mouse_y, mouse_event);
    time := seconds_since_init();
    ui_per_frame_update(win, cast(s32) width, cast(s32) height, time);
    // The Subwindow starts open, but pressing the Close button can close it.
    if subwindow_newgame.open {  
      add_subwindow(*subwindow_newgame);
    }

    render_right_panel();
    render_ui();

    // sound effects.
    //Sound.update();
    draw_popups();  // This draws Subwindows as well.
    sleep_milliseconds(20);
    simp.swap_buffers(win);
    reset_temporary_storage();
    looptime_end = cast(float)seconds_since_init();
  }

}

#scope_file

render_arrow :: (arrow: Arrow, corner_x: float, corner_y: float, square: float) {

  arrow_point :: (index: int, corner_x: float, corner_y: float, square: float, half_square: float) -> Vector2 {
    index = orient_piece(cast(u8)index);
    row, col := row_col_of(cast(u8)index);
    return make_vector2(corner_x + square * row + half_square, corner_y + square * col + half_square);
  }

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
}

engines_panel :: (height: float, board_margin: float, width: float, k: float) #expand {
  r := get_rect(height + 3.0, height - board_margin - 3.0 - k, width - board_margin*2.5 - height - 6.0, k);

  engine_names: [..] string;
  engine_names.allocator = temp;
  for *engine: engines_array {
    array_add(*engine_names, engine.name);
  }
  array_add(*engine_names, get_ui_str().add_engine);

  dropdown(r, engine_names, *engine_selection);
  slider_theme := *default_overall_theme.slider_theme;
  label_theme := *default_overall_theme.label_theme;
  text_theme: *Text_Input_Theme = *default_overall_theme.text_input_theme;
  XVAL :: 2.5;

  r.y -= k + 10.0;
  if engine_selection == engine_names.count - 1 {
    label(r, get_ui_str().name, label_theme);
    r.x += k * XVAL;
    r.w -= k * XVAL;
    act1, _, name_state := text_input(r, engine_name_input, text_theme);
    if act1 & .TEXT_MODIFIED {
      engine_name_input = get_result(name_state);
    }
    r.x -= k * XVAL;
    r.w += k * XVAL;
    r.y -= k + 10.0;
    label(r, get_ui_str().path, label_theme);
    r.x += k * XVAL;
    r.w -= k * XVAL;
    act2, __, engine_path_state := text_input(r, engine_path_input, text_theme);
    if act2 & .TEXT_MODIFIED {
      engine_path_input = get_result(engine_path_state);
    }
    r.x -= k * XVAL;
    r.w += k * XVAL;
    r.y -= k + 10.0;
    label(r, get_ui_str().protocol, label_theme);
    r.x += k * XVAL;
    r.w -= k * XVAL;
    dropdown(r, .["uci", "ucci"], *protocol_choice);
    r.y -= k + 10.0;

    if button(r, get_ui_str().load_engine) {
      path := get_result(engine_path_state);
      engine, success := load_engine(path, cast(Protocol)protocol_choice);
      if success == true {
        name := get_result(name_state);
        if name {
          // (Daniel - Mar 6, 2023.) Memory leak. String not freed.
          // will address issue if we are repeatedly opening and closing engines 100 times.
          // constantly, but I don't think this happens often, so won't bother with this
          engine.name = copy_string(name);
        } else {
          engine.name = copy_string(path);
        }

        array_add(*engines_array, engine);
        reset(name_state);
        reset(engine_path_state);
      }
    }
  } else {
    y := r.y;
    engine := *engines_array[engine_selection];
    if engine.options.count == 0 {
      label(r, get_ui_str().no_options_available, label_theme);
      return;
    }

    r.y = board_margin + 3.0;
    if button(r, get_ui_str().cancel) {
      for *option: engine.options {
          using option;
          check_value = check_value_old;
          spin_value = spin_value_old;
          combo_value = combo_value_old;
          string_value = string_value_old;
      }
    }

    protocol_prefix := "";
    if engine.protocol == Protocol.uci then {
      protocol_prefix = "setoption name";
    } else if engine.protocol == Protocol.ucci then {
      protocol_prefix = "setoption";
    }

    protocol_suffix := "";
    if engine.protocol == Protocol.uci then {
      protocol_suffix = "value ";
    } else if engine.protocol == Protocol.ucci then {
      protocol_suffix = "";
    }

    r.y += k * 1.1;
    if button(r, get_ui_str().set_option) {
      process := *engine.process;
      for *option: engine.options {
        using option;
        if type == {
        case .check;
          if check_value != check_value_old {
            check_value_old = check_value;
            opt := tprint("%1 %2 %3%4\n", protocol_prefix, name, protocol_suffix, check_value);
            write_to_process(process, to_u8_array(opt));
          }
        case .spin;
          if spin_value != spin_value_old {
            spin_value_old = spin_value;
            opt := tprint("%1 %2 %3%4\n", protocol_prefix, name, protocol_suffix, spin_value);
            write_to_process(process, to_u8_array(opt));
          }
        case .combo;
          if combo_value != combo_value_old {
            combo_value_old = combo_value;
            opt := tprint("%1 %2 %3%4\n", protocol_prefix, name, protocol_suffix, combo_value);
            write_to_process(process, to_u8_array(opt));
          }
        case .button;
        case .ucci_string;
          if !equal(string_value, string_value_old) {
            string_value = string_value_old;
            opt := tprint("%1 %2 %3%4\n", protocol_prefix, name, protocol_suffix, string_value);
            write_to_process(process, to_u8_array(opt));
          }
        }
      }
    }

    r.y += k * 1.1;
    r.h = y - r.y + k;
    if r.h < k {
      return;
    }

    region, inside := begin_scrollable_region(r);
    s := inside;
    s.y = s.y + s.h - k;
    s.h = k;
    s.y += engine_scroll_value;
    index := 0;
    for *option : engine.options {
      name := option.name;
      if option.type == {
      case .check;
        if base_checkbox(s, name, option.check_value, identifier=index) {
          option.check_value = !option.check_value;
        }
        index += 1;
      case .spin;
        slider(s, *option.spin_value, option.spin_min, option.spin_max, 1, slider_theme, tprint("% ", name), "", identifier=index);
        index += 3;
      case .combo;
        label(s, name, label_theme);
        s.x += k * XVAL * 2;
        s.w -= k * XVAL * 2;
        dropdown(s, option.combo_values, *option.combo_value, identifier=index);
        s.w += k * XVAL * 2;
        s.x -= k * XVAL * 2;
        index += 1;
      case .button;
        process := *engine.process;
        if button(s, name, identifier=index) {
          prefix := "";
          if engine.protocol == Protocol.uci then {
            prefix = "setoption name";
          } else if engine.protocol == Protocol.ucci then {
            prefix = "setoption";
          }
          opt := tprint("% %\n", prefix, name);
          write_to_process(process, to_u8_array(opt));
        }
        index += 1;
      case .ucci_string;
        label(s, name, label_theme);
        s.x += k * XVAL * 2;
        s.w -= k * XVAL * 2;
        action, console_string, state := text_input(s, option.string_value, text_theme, identifier=index);
        s.w += k * XVAL * 2;
        s.x -= k * XVAL * 2;
        index += 1;
      }
      s.y -= floor(k*1.1 + .5);
    }
    end_scrollable_region(region, s.x + s.w, s.y, *engine_scroll_value);
  }
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
  piece := xiangqi.board[row + col * 9];
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

show_pv_line :: (using pv_line: *PV_Info) -> string {

  builder: String_Builder;
  builder.allocator = temp;
  if pv_line.mate == false {
    if eval >= 0 {
      print_to_builder(*builder, "[%.%] ", eval / 100, eval % 100);
    } else {
      score := -eval;
      print_to_builder(*builder, "[-%.%] ", score / 100, score % 100);
    }
  } else {
    print_to_builder(*builder, "[Mate in %] ", eval);
  }

  if depth != -1 {
    print_to_builder(*builder, "depth % | ", depth);
  }

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
    print_to_builder(*builder, "% ", move);
  }

  return builder_to_string(*builder,, allocator=temp);
}

width:  float = 680;
height: float = 680;
sprites: simp.Texture;
setting_sprite: simp.Texture;
piece_style: enum s32 { European; Classic; Stylized; } = .Classic;
board_style: enum s32 { White; Mocha; Bamboo; Rust; } = .White;
language: enum s32 { English; Chinese; } = .English;
orient := false;
blindfold: bool = false;
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
sound_quiet_move: Sound.Sound_Data;
sound_capture_move: Sound.Sound_Data;

counter_history: [1024] s8;
counter30: s8 = 0;
moves_made_count: int = 0;

// status label.
status_string: string;
move_list_scroll_value: float = 0;

// engine(s).
engines_array: [..] Engine;

// automated testing engines parameters
auto_test_engines: bool = false;

random_pick_auto_test_ai :: () {
  popcount :: (value: u64) -> u64 #expand {
    result: u64 = ---;
    #asm { popcnt.q  result, value; }
    return result;
  }

  bsf :: (input: u64) -> int #expand {
    result: int = ---;
    #asm { bsf.q     result, input; }
    return result;
  }
  // TODO: this is some hacky ugly glue code to get something working...
  // DANIEL - Mar 10, 2023.
  engine_test_booleans_local := ifx engine_test_booleans == 0 then 1 else engine_test_booleans;
  numbits := popcount(engine_test_booleans_local);
  r := random_get() % numbits;
  bits := engine_test_booleans_local;
  while r {
    bits &= bits - 1;
    r -= 1;
  }
  index := bsf(bits);

  if random_get() & 1 {
    red_ai = engine_test_choice;
    black_ai = index;
  } else {
    black_ai = engine_test_choice;
    red_ai = index;
  }

}

random_pick_board_position :: () {
  r := random_get() % xiangqi_openings.count;
  fen := xiangqi_openings[r]; 
  xiangqi_fen(*xiangqi, fen);
  fen_string = copy_string(fen);
}

stage_sound :: (data: *Sound.Sound_Data, category := Sound.Sound_Category.GENERAL_SFX, perturb := true) -> *Sound.Sound_Stream {
  /*stream := Sound.make_stream(data, category);
  if perturb {
    stream.user_volume_scale = random_get_within_range(0.5, 1.4);
    stream.rate_scale        = random_get_within_range(0.7, 1.22);
  }
  return stream;*/
  return null;
}

init_sound :: () {
  /*sound_quiet_move = Sound.load_audio_file("data/quiet_move.wav");
  assert(sound_quiet_move.loaded);

  sound_capture_move = Sound.load_audio_file("data/capture_move.wav");
  assert(sound_capture_move.loaded);

  // initialize sound player
  Sound.sound_player_init(.{});
  */
}

play_sound :: (sound: *Sound.Sound_Data) {
  //stream := stage_sound(sound, .GENERAL_SFX, true);
  //Sound.start_playing(stream);
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

// flip the index.
orient_index :: (index: u8) -> u8 {
  row := (index % 9);
  col := (index / 9);
  row = 8 - row;
  col = 9 - col;
  return row + col * 9;
}

row_col_of :: (sq: int) -> int, int {
  row := (sq % 9);
  col := (sq / 9);
  return row, col;
}

gui_undo_move :: () {

  human_turn :: () -> bool #expand {
    if xiangqi.turn == 0 then {
      return red_ai == -1;
    } else {
      return black_ai == -1;
    }
  }

  if moves_made_count <= 0 then {
    return;
  }

  moves_made_count -= 1;
  move := xiangqi.hashes.info[moves_made_count].move;
  unmake_move(*xiangqi, move);

  while moves_made_count >= 0 && !human_turn() {
    moves_made_count -= 1;
    move := xiangqi.hashes.info[moves_made_count].move;
    unmake_move(*xiangqi, move);
  }

  counter30 = counter_history[moves_made_count];
  reset(*moves);
  legal_moves(*xiangqi, *moves);

  // undo move.
  status_string = "";

  if moves_made_count > 0 then {
    peek := moves_made_count - 1;
    last_move := xiangqi.hashes.info[peek].move;
    prev_from = last_move.from;
    prev_to   = last_move.to;
  } else {
    prev_from = 0xFF;
    prev_to   = 0xFF;
  }
}

gui_redo_move :: () {
  mov := xiangqi.hashes.info[moves_made_count].move;
  if is_null(mov) then return;
  next := xiangqi.hashes.info[moves_made_count+1].move;
  gui_make_move(mov, true);
  xiangqi.hashes.info[moves_made_count].move = next;
}

chases: [8] Move32;
chase_count := 0;

gui_make_move :: (move: Move32, animate: bool) {
  for m: moves {
    if m == move then {
      clock_move_incr();
      prev_from = move.from;
      prev_to   = move.to;
      make_move(*xiangqi, move);
      get_evade(*xiangqi, move, chases, chase_count);

      // add another move.
      xiangqi.hashes.info[moves_made_count].move = move;
      counter_history[moves_made_count] = counter30;
      counter30 = incr_count30(move, counter30);
      moves_made_count += 1;

      if animate == true && mov_anim_state == MovAnim.Idle then {
        mov_anim_time = 0.0;
        mov_anim_state = MovAnim.Play;
      }

      /*sound_data: *Sound.Sound_Data;
      if move.capture == 0 {
        sound_data = *sound_quiet_move;
      } else {
        sound_data = *sound_capture_move;
      }
      if sound == true then {
        play_sound(sound_data);
      }*/
      reset(*moves);
      legal_moves(*xiangqi, *moves);
      status_string = "";

      att := attackers(*xiangqi);
      if incheck(*xiangqi, att) then {
        chase_count = 0;
        status_string = get_ui_str().status_string[0];
        mark_previous_move_check(*xiangqi);
      } else if is_capture(move) || is_pawn_advance(move) {
        mark_previous_move(*xiangqi, .Cancel);
        chase_count = 0;
      } else if is_quiet(move) {
        chase_count = get_chases(*xiangqi, chases);
        mark_previous_move(*xiangqi, .Idle);
      } 

      judge_state, violation_level := judge_ntimes(*xiangqi, 4);

      if judge_state == {
      case .Undecided;
      case .Win;
        winner: GameEnd;
        if xiangqi.turn == 0 {
          if violation_level == .PerpetualCheck {
            status_string = get_ui_str().status_string[3];  
          } else if violation_level == .PerpetualChase {
            status_string = get_ui_str().status_string[8];  
          }
          winner = .Red_Wins;
        } else {
          if violation_level == .PerpetualCheck {
            status_string = get_ui_str().status_string[4];  
          } else if violation_level == .PerpetualChase {
            status_string = get_ui_str().status_string[9];  
          }
          winner = .Black_Wins;
        }
        on_game_end(winner);
      case .Draw;
        status_string = get_ui_str().status_string[5];
        on_game_end(.Draw);
      case .Loss;
      }

      if moves.count == 0 then {
        winner: GameEnd;
        if xiangqi.turn == 0 {
          status_string = get_ui_str().status_string[1];  
          winner = .Black_Wins;
        } else {
          status_string = get_ui_str().status_string[2];  
          winner = .Red_Wins;
        }
        on_game_end(winner);
      }

      if moves_made_count >= xiangqi.hashes.info.count || is_draw(*xiangqi) {
        status_string = get_ui_str().status_string[6];
        on_game_end(.Draw);
      }

      if counter30 >= 120 {
        status_string = get_ui_str().status_string[7];
        on_game_end(.Draw);
      }
      move_list_scroll_value = 10000;
      break;
    }
  }
}

GameEnd :: enum {
  Red_Wins;
  Black_Wins;
  Draw;
}

// TODO: Need to handle repetitions/draws/etc. "Chasing" rules...
// winner = true, RED wins. 
// winner = false, BLACK wins.
on_game_end :: (winner: GameEnd) {

  // record down the game to a pgn file.
  builder: String_Builder;
  builder.allocator = temp;
  create_pgn(*builder, winner);

  if number_of_games > 0 then {
    number_of_games -= 1;
  }

  if number_of_games <= 0 then {
    auto_test_engines = false;
  }

  for *engine: engines_array {
    engine.state = .newgame;
  }

  counter30 = 0;
  // TODO: actually handle auto engine testing correctly...
  if auto_test_engines == true {
    subwindow_fenstring = "startpos";
    status_string = "";
    if engine_test_state == .SWITCH_SIDES {
      xiangqi_fen(*xiangqi, fen_string);
      moves_made_count = 0;
      reset(*moves);
      legal_moves(*xiangqi, *moves);
      prev_from = 0xFF;
      prev_to   = 0xFF;
      r_time_ms = r_time_manager.clock_ms;
      b_time_ms = b_time_manager.clock_ms;

      // switch sides.
      swap := red_ai;
      red_ai = black_ai;
      black_ai = swap;

      engine_test_state = .PICK_RANDOM_POSITION;
    } else {
      random_pick_board_position();
      moves_made_count = 0;
      reset(*moves);
      legal_moves(*xiangqi, *moves);
      prev_from = 0xFF;
      prev_to   = 0xFF;
      r_time_ms = r_time_manager.clock_ms;
      b_time_ms = b_time_manager.clock_ms;
      random_pick_auto_test_ai();
      engine_test_state = .SWITCH_SIDES;
    }
  } else {
    red_ai = -1;
    black_ai = -1;
    r_time_manager.time_control = .None;
    b_time_manager.time_control = .None;
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
  options: [..] Engine_Option;
}

Protocol :: enum u8 { 
  uci; 
  ucci; 
}

UCI_Types :: enum {
  check;
  spin;
  combo;
  button;
  ucci_string;
}

EngineState :: enum {
  ucciok;
  isready;
  newgame;
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
  mate:  bool = false;
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
      token, success := parse_token(line);
      if success == false then
        continue;
      eval, success= := string_to_int(token);
      if success == true {
        pv_info.eval = eval;
        pv_info.mate = false;
        continue;
      } else {
        if token == {
        case "cp"; 
          pv_info.mate = false;
        case "mate"; 
          pv_info.mate = true;
        }
      }

      eval, success = parse_int(line);
      if success == true {
        pv_info.eval = eval;
      }
    case "currmove";
      return pv_info, false;
    case "pv";
      // TODO: Need more robust input parsing...
      while i < 16 && line.count > 0 {
        token, success := parse_token(line);
        if success == false || token.count != 4 then
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

engine_log :: (engine: *Engine, fmt: string, args: ..Any) {
  if engine_logging == true {
    print("[%] ", engine.name);
    print(fmt, ..args);
  } 
} @PrintLike

engine_logging := true;

update_ucci :: (engine: *Engine, id: int, protocol: string) {

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
        // TODO: (DANIEL Feb 26, 2023) I don't know what is the correct command for
        // "Think for x time per move..."
        // If there is any UCCI Protocol documentation for this command, I would love to support
        // that command...
        // Therefore: I'm just going with UCI command. This does not work with ElephantEye UCCI,
        // but... it should be good for our Xiangqi Engine. This is the tradeoff I'm making...
        return tprint("go movetime %1%2", ms, NEWLINE);
      }

    case .Depth;
      return tprint("go depth %1%2", timeManager.depth, NEWLINE);
    }
  }

  process := *engine.process;
  state := engine.state;
  defer engine.state = state;
  SIZE :: 32768;
  #if OS == .WINDOWS {
    NEWLINE :: "\n"; // normalized line endings.
  } else {
    NEWLINE :: "\n";
  }

  if state == {

  case .ucciok;
    out_buff := NewArray(SIZE, u8,, allocator=temp);
    err_buff: [] u8; // nothing.
    success, output_bytes := read_from_process(process, out_buff, err_buff, timeout_ms=0);
    messages: string;
    messages.data = out_buff.data;
    messages.count = output_bytes;
    normalize_line_endings(*messages);

    ok := tprint("%1ok", protocol);
    for msg, index: split(messages, NEWLINE) {
      message := msg;
      if message then
        engine_log(engine, "%\n", message);

      // either ucciok or uciok
      if equal(message, ok) then {
        state = .isready;
        engine.timer = FLOAT32_INFINITY;
      } else if begins_with(message, "option name") {
        message = advance(message, 11);
        message = eat_spaces(message);
        TF, option := parse_uci_option(message);
        if TF {
          array_add(*engine.options, option);
        }
      } else if begins_with(message, "option") {
        message = advance(message, 6);
        message = eat_spaces(message);
        TF, option := parse_uci_option(message);
        if TF {
          array_add(*engine.options, option);
        }
      }
    }

  case .isready;
    out_buff := NewArray(SIZE, u8,, allocator=temp);
    err_buff: [] u8; // nothing.
    success, output_bytes := read_from_process(process, out_buff, err_buff, timeout_ms=0);
    messages: string;
    messages.data = out_buff.data;
    messages.count = output_bytes;
    normalize_line_endings(*messages);

    for msg, index: split(messages, NEWLINE) {
      message := msg;
      if message then
        engine_log(engine, "%\n", message);
      if equal(message, "readyok") then {
        state = .uccinewgame;
        engine.timer = FLOAT32_INFINITY;
      } 
    }
  case .newgame;
    state = .uccinewgame;
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
      out_buff := NewArray(SIZE, u8,, allocator=temp);
      err_buff: [] u8; // nothing.
      success, output_bytes := read_from_process(process, out_buff, err_buff, timeout_ms=0);
      messages: string;
      messages.data = out_buff.data;
      messages.count = output_bytes;
      normalize_line_endings(*messages);

      for msg, index: split(messages, NEWLINE) {
        message := msg;
        if message {
          engine_log(engine, "%\n", message);
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
          if equals(message, "nobestmove") {
            
          } else {
            mov_token := parse_token(*message);
            mov := to_move32(*xiangqi, mov_token);
            gui_make_move(mov, true);
            state = .idle;
          }
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
  case .newgame;
    state = .uccinewgame;
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
    gostr := ucci_go_command(engine, timeManager);
    write_to_process(process, to_u8_array(gostr));

  case .bestmove;
    // waiting to get the best move.
    // don't do anything.
  case .bug;

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
    move := xiangqi.hashes.info[index].move;
    print_to_builder(*builder, " %", move);
  }
  append(*builder, NEWLINE);
  return builder_to_string(*builder,, allocator=temp);
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
arrow_color :: Vector4.{.0, .0, .0, .33};
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
  print("[%] shutdown engine\n", engine.name);
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
  e, success := load_engine("orange", .ucci);
  if success == true {
    e.name = "orange";
    print("Loading engine: %\n", e.name);
    array_add(*engines_array, e);
  }
}

protocol_choice: s32 = 1;
newgame_w_choice: s32 = 0;
newgame_b_choice: s32 = 0;
subwindow_fenstring := "startpos";

game_mode_type: s32 = 0;
subwindow_filestring := "";
filename_pgn: string = "game.pgn";
bookfilename: string = "data/xiangqi_fens.txt";
number_of_games: s32 = 1;

draw_subwindow_newgame :: (r: Rect, data: *void) {
  subwindow_newgame.title_text = get_ui_str().new_game;

  time_management_ui :: (rect: *Rect, name: string, time_manager: *TimeManager, k: float, id: int) {
    slider_theme := *default_overall_theme.slider_theme;
    label_theme := *default_overall_theme.label_theme;
    text_theme: *Text_Input_Theme = *default_overall_theme.text_input_theme;
    label(rect, name, label_theme);
    rect.x += k * 2.5;
    dropdown(rect, get_ui_str().time_ctrl, cast(*s32)*time_manager.time_control, identifier=id);
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

  // themes
  slider_theme := *default_overall_theme.slider_theme;
  label_theme := *default_overall_theme.label_theme;
  text_theme: *Text_Input_Theme = *default_overall_theme.text_input_theme;
  get_engine_names :: (none: bool) -> [..] string {
    arr: [..] string;
    arr.allocator = temp;
    if none == true then {
      array_add(*arr, "(none)");
    }
    for engine: engines_array {
      array_add(*arr, engine.name);
    }
    return arr;
  }

  display_settings = false;
  k := clamp(height * 0.05, 15.0, 45.0);
  rect := get_rect(r.x + 3, r.y + r.h - k - 3, r.w - k*2.5 - 9, k);
  label(rect, get_ui_str().mode, label_theme);
  rect.x += k * 2.5;
  // TODO...UI is buggy. sometimes you press a button and it does not respond...
  dropdown(rect, get_ui_str().modes, *game_mode_type);
  rect.x -= k * 2.5;
  rect.y -= k * 1.6;
  if game_mode_type == 0 {
    arr := get_engine_names(true);
    label(rect, get_ui_str().fen, label_theme);
    rect.x += k * 2.5;
    action_c, _, fen_state := text_input(rect, subwindow_fenstring, text_theme);
    if action_c & .TEXT_MODIFIED {
      subwindow_fenstring = get_result(fen_state);
    }
    rect.y -= k * 1.1;
    rect.x -= k * 2.5;
    label(rect, get_ui_str().red, label_theme);
    rect.x += k * 2.5;
    dropdown(rect, arr, *newgame_w_choice);
    rect.x -= k * 2.5;
    rect.y -= k * 1.1;
    label(rect, get_ui_str().black, label_theme);
    rect.x += k * 2.5;
    dropdown(rect, arr, *newgame_b_choice);
    rect.y -= k * 1.1;
    if base_checkbox(rect, get_ui_str().equal_time_control, equal_time_control) {
      equal_time_control = !equal_time_control;
    }
 
    rect.x -= k * 2.5;
    rect.y -= k * 1.1;
 
    time_management_ui(*rect, ifx equal_time_control then get_ui_str().time else get_ui_str().red, *r_time_manager, k, 0);
    if equal_time_control == false {
      time_management_ui(*rect, get_ui_str().black, *b_time_manager, k, 3);
    } else {
      b_time_manager = r_time_manager;
    }
 
    rect.x += k * 2.5;
    if button(rect, get_ui_str().play) {
      counter30 = 0;
      subwindow_newgame.open = false;
      str := get_result(fen_state);
      if !str || equal(str, "startpos") then {
        xiangqi_startpos(*xiangqi);
        if fen_string {
          free(fen_string);
        }
        fen_string = "";
      } else {
        if xiangqi_fen(*xiangqi, str) {
          fen_string = copy_string(str);
        } else {
          xiangqi_startpos(*xiangqi);
          if fen_string {
            free(fen_string);
          }
          fen_string = "";
        }
      }
      set_input(fen_state, "startpos"); 
      subwindow_fenstring = "startpos";
      status_string = "";
      moves_made_count = 0;
      reset(*moves);
      legal_moves(*xiangqi, *moves);
      prev_from = 0xFF;
      prev_to   = 0xFF;
      red_ai = newgame_w_choice - 1;
      black_ai = newgame_b_choice - 1;
      r_time_ms = r_time_manager.clock_ms;
      b_time_ms = b_time_manager.clock_ms;
      auto_test_engines = false;
    }
  } else if game_mode_type == 1 {
    arr := get_engine_names(false);
    label(rect, get_ui_str().file, label_theme);
    rect.x += k * 2.5;
    ac3, _, file_state := text_input(rect, bookfilename, text_theme);
    if ac3 & .TEXT_MODIFIED {
      bookfilename = get_result(file_state);
    }
    rect.x -= k * 2.5;
    rect.y -= k * 1.1;
    label(rect, "Save PGN", label_theme);
    rect.x += k * 2.5;
    ac4, __, pgn_state := text_input(rect, filename_pgn, text_theme);
    if ac4 & .TEXT_MODIFIED {
      filename_pgn = get_result(pgn_state);
    }
    rect.y -= k * 1.1;
    slider(rect, *number_of_games, 1, 10_000, 1, slider_theme, prefix="Number of Games: ");

    rect.y -= k * 1.1;
    rect.x -= k * 2.5;
    label(rect, "Test", label_theme);
    rect.x += k * 2.5;
    dropdown(rect, arr, *engine_test_choice);
    rect.y -= k * 1.1;

    rect.x -= k * 2.5;
    label(rect, "Opponents", label_theme);
    rect.x += k * 2.5;
    // ... TODO: This code assumes we have only 64 engines loaded...
    bit: u64 = 1;
    for *engine, index: engines_array {
      TF := (engine_test_booleans & bit) != 0;
      if base_checkbox(rect, engine.name, TF, identifier=index) {
        engine_test_booleans ^= bit;
      }

      rect.y -= k * 1.1;
      bit <<= 1;
    }

    rect.y -= k * 1.1;
    rect.x -= k * 2.5;
    time_management_ui(*rect, get_ui_str().time, *r_time_manager, k, 0);
    b_time_manager = r_time_manager;

    rect.y -= k * 1.1;
    rect.x += k * 2.5;
    // TODO: Copy/pasted the code...
    if button(rect, get_ui_str().play) {
      counter30 = 0;
      subwindow_newgame.open = false;
      subwindow_fenstring = "startpos";
      status_string = "";
      if fen_string {
        free(fen_string);
      }
      fen_string = "";
      random_pick_board_position();
      moves_made_count = 0;
      reset(*moves);
      legal_moves(*xiangqi, *moves);
      prev_from = 0xFF;
      prev_to   = 0xFF;
      r_time_ms = r_time_manager.clock_ms;
      b_time_ms = b_time_manager.clock_ms;
      auto_test_engines = true;
      random_pick_auto_test_ai();
      engine_test_state = .SWITCH_SIDES;
    }
  }

}

// engine testing parameters
engine_test_choice: s32 = 0;
engine_test_booleans: u64 = 0;

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

right_panel_display: s32 = 0;
engine_selection: s32 = 0;

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

UI_String :: struct {
  new_game: string = "New Game";
  undo: string = "Undo (Ctrl+Z)";
  redo: string = "Redo (Ctrl+Y)";
  piece_style: [] string = string.["European Set", "Chinese Set", "Chinese Calligraphy Set"];
  board_style: [] string = string.["White Board", "Mocha Board", "Bamboo Board", "Rust Board"];
  right_panel: [] string = string.["Moves on Right Panel", "Engines Info on Right Panel", "None"];
  show_moves: string = "Show Moves";
  orientation: string = "Orientation";
  audio: string = "Audio";
  highlight_move: string = "Highlight Move";
  animations: string = "Animations";
  animation_speed: string = "Animation Speed ";
  blindfold: string = "Blindfold";
  logging: string = "Engine Logging";
  red_pv: string = "Red PV";
  black_pv: string = "Black PV";
  add_engine: string = "Add Engine";
  name: string = "Name";
  path: string = "Path";
  protocol: string = "Protocol";
  load_engine: string = "Load Engine";
  no_options_available: string = "No Options Available";
  cancel: string = "Cancel";
  set_option: string = "Set Option";
  status_string: [] string = string.[
    "Check",
    "Checkmate. Black Wins",
    "Checkmate. Red Wins",
    "Perpetual Check. Red Wins",
    "Perpetual Check. Black Wins",
    "Threefold Repetition. No Rule Violation. Draw.",
    "Draw by Insufficient Material",
    "Draw by 60 Move Rule",
    "Perpetual Chase. Red Wins",
    "Perpetual Chase. Black Wins",
  ];
  time: string = "Time";
  time_ctrl: [] string = string.["None", "Clock", "Time Per Move", "Depth"];
  mode: string = "Mode";
  modes: [] string = string.["Normal Game", "Engine Testing"];
  fen: string = "Fen";
  red: string = "Red";
  black: string = "Black";
  equal_time_control: string = "Equal Time Control";
  play: string = "Play";
  file: string = "File";
}

English_UI := UI_String.{};
Chinese_UI := UI_String.{
  "新游戏",
  "悔棋 (Ctrl+Z)",
  "重做 (Ctrl+Y)",
  string.["欧洲棋子", "中国棋子", "中国书法棋子"],
  string.["白棋盘", "咖啡棋盘", "竹子棋盘", "铁棋盘"],
  string.["显示着棋历史", "显示引擎配置", "无"],
  "显示可行走法",
  "棋盘方向",
  "音效",
  "高亮走法",
  "动画",
  "动画速度",
  "盲棋模式",
  "日志",
  "红方走法",
  "黑方走法",
  "添加引擎",
  "引擎名",
  "引擎路径",
  "引擎协议",
  "加载引擎",
  "无可用选项",
  "取消",
  "设置选项",
  string.[
    "将军",
    "将死. 黑方胜",
    "将死. 红方胜",
    "违规长将. 红方胜",
    "违规长将. 黑方胜",
    "三次重复局面. 无违规. 和棋.",
    "和棋. 双方无足够子力",
    "和棋. 60步规则",
    "违规长捉. 红方胜",
    "违规长捉. 黑方胜",
  ],
  "时间",
  string.["无", "限时", "限制每步搜索时间", "限制搜索深度"],
  "模式",
  string.["普通对局", "引擎测试"],
  "Fen",
  "红方",
  "黑方",
  "等时控制",
  "开始游戏",
  "文件",
};

get_ui_str :: () -> *UI_String {
  if language == .English then
    return *English_UI;
  if language == .Chinese then
    return *Chinese_UI;
  return *English_UI;
}

parse_uci_option :: (message: string) -> bool, Engine_Option #must {
  string_to_uci_type :: (token: string) -> UCI_Types, TF: bool = true {
    if token == {
    case "check";
      return .check;
    case "spin";
      return .spin;
    case "combo";
      return .combo;
    case "button";
      return .button;
    case "string";
      return .ucci_string;
    }
    return .check, false;
  }

  // TODO: this may leak memory on bad input.
  option: Engine_Option;
  TF: bool;
  option_name: string;
  uci_type: string;
  rest: string;

  TF, option_name, rest = split_from_right(message, " type");
  if TF == false return false, option;

  option.name = copy_string(option_name);

  rest = eat_spaces(rest);
  uci_type, TF = parse_token(*rest);
  if TF == false return false, option;

  uci_option_type: UCI_Types;
  uci_option_type, TF = string_to_uci_type(uci_type);
  if TF == false return false, option;

  option.type = uci_option_type;
  
  rest = eat_spaces(rest);

  combo_default: string;

  token: string;
  while rest {
    token, TF = parse_token(*rest);
    if TF == false return false, option;
    rest = eat_spaces(rest);
    if token == {
    case "default";
      value,TF := parse_token(*rest);
      rest = eat_spaces(rest);
      if uci_option_type == {
      case .check;
        option.check_value,TF = parse_bool(*value);
        option.check_value_old = option.check_value;
        if TF == false return false, option;
      case .spin;
        option.spin_value,TF = parse_int(*value);
        option.spin_value_old = option.spin_value;
        if TF == false return false, option;
      case .combo;
        combo_default = value;
      case .button;
        return false, option;
      case .ucci_string;
      }

    case "max";
      value,TF := parse_token(*rest);
      if TF == false return false, option;
      rest = eat_spaces(rest);
      if uci_option_type == {
      case .check;
        return false, option;
      case .spin;
        option.spin_max,TF = parse_int(*value);
        if TF == false return false, option;
      case .combo;
      case .button;
        return false, option;
      case .ucci_string;
        return false, option;
      }

    case "min";
      value,TF := parse_token(*rest);
      if TF == false return false, option;
      rest = eat_spaces(rest);
      if uci_option_type == {
      case .check;
        return false, option;
      case .spin;
        option.spin_min,TF = parse_int(*value);
        if TF == false return false, option;
      case .combo;
      case .button;
        return false, option;
      case .ucci_string;
        return false, option;
      }
    case "var";
      value,TF := parse_token(*rest);
      if TF == false return false, option;
      rest = eat_spaces(rest);

      combo_option := copy_string(value);
      array_add(*option.combo_values, combo_option);

    case;
      return false, option;
    }
  }

  if uci_option_type == .combo then {
    found : s32 = -1;
    for combos, index: option.combo_values {
      if equal(combo_default, combos) then {
        found = xx index;
        break;
      }
    }
    if found == -1 return false, option;
    option.combo_value = found;
    option.combo_value_old = found;
  }

  return true, option;

}


create_pgn :: (builder: *String_Builder, winner: GameEnd) {
  player_name :: (index: int) -> string {
    if index == -1 then
      return "John Doe";
    return engines_array[index].name;
  }

  time := to_calendar(current_time_consensus(), .LOCAL);
  year := time.year;
  month := time.month_starting_at_0 + 1;
  day := time.day_of_month_starting_at_0 + 1;

  red_player := player_name(red_ai);
  black_player := player_name(black_ai);

  append(builder, "[Event \"Xiang Qi Computer Game\"]\n");
  append(builder, "[Site \"Xiang Qi Application\"]\n");
  print_to_builder(builder, "[Date \"%1.%2.%3\"]\n", formatInt(year, minimum_digits=4), formatInt(month, minimum_digits=2), formatInt(day, minimum_digits=2));
  print_to_builder(builder, "[Round \"%1\"]\n", number_of_games);
  print_to_builder(builder, "[White \"%1\"]\n", red_player); 
  print_to_builder(builder, "[Black \"%1\"]\n", black_player);

  if #complete winner == {
  case .Red_Wins;
    append(builder, "[Result \"1-0\"]\n");
  case .Black_Wins;
    append(builder, "[Result \"0-1\"]\n");
  case .Draw;
    append(builder, "[Result \"1/2-1/2\"]\n");
  }

  append(builder, "[Variant \"xiangqi\"]\n");
  print_to_builder(builder, "[Fen \"%1\"]\n", fen_string);

  i := 0;
  while i < moves_made_count {
    print_to_builder(builder, "% ", xiangqi.hashes.info[i].move);
    i += 1;
  }

  append(builder, #char "\n");
  append(builder, #char "\n");

  // TODO: Robustness.
  file, success := file_open(filename_pgn, for_writing=true, keep_existing_content=true);
  if success {
    data := builder_to_string(builder,, allocator=temp);
    file_write(*file, data);
    file_close(*file);
  }
}

engine_test_state: Engine_Test = .PICK_RANDOM_POSITION;

Engine_Test :: enum {
  PICK_RANDOM_POSITION;
  SWITCH_SIDES;
}

is_quiet :: (mov: Move32) -> bool #expand {
  return mov.capture == 0;
}

// todo: fix this!
is_draw :: (xiangqi: *Xiangqi) -> bool {

  count_offensive_pieces :: (pieces: Pieces) -> int {
    using pieces;
    return kni.count + rook.count + cannon.count + pawn.count;
  }

  num := count_offensive_pieces(xiangqi.pieces[0]);
  if num > 0 then
    return false;
  num = count_offensive_pieces(xiangqi.pieces[1]);
  if num > 0 then
    return false;

  return true;

}

to_move32 :: (xiangqi: *Xiangqi, str: string) -> Move32 {
  row_from := str[0] - #char "a";
  col_from := str[1] - #char "0";
  row_to   := str[2] - #char "a";
  col_to   := str[3] - #char "0";
  from := row_col_to_index(row_from, col_from);
  to   := row_col_to_index(row_to, col_to);
  move: Move32;
  move.from = cast(u8)from;
  move.to   = cast(u8)to;
  move.piece = xiangqi.board[from];
  move.capture = xiangqi.board[to];
  return move;
}

incr_count30 :: (move: Move32, count30: s8) -> s8 #expand {
  if is_capture(move) || is_pawn_advance(move) {
    return 0;
  }
  return count30 + 1;
}

Engine_Option :: struct {
  name: string;
  type: UCI_Types;
  check_value: bool;
  spin_value: int;
  spin_max: int;
  spin_min: int;
  combo_value: s32;
  combo_values: [..] string;
  string_value: string;
  check_value_old: bool;
  spin_value_old: int;
  combo_value_old: s32;
  string_value_old: string;
}

engine_scroll_value: float;
engine_name_input: string;
engine_path_input: string;

#import "Window_Creation";
#import "System";
#import "Basic";
simp :: #import "Simp";
#import "Input";
#import "Math";
#import "GetRect";
Sound :: #import "Sound_Player";
#import "Wav_File";
#import "File";
#import "Random";
#import "Process";
