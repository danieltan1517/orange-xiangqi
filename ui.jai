main :: () {

  set_default_theme(default_theme_procs[Default_Themes.Grayscale]());
  win := create_window(width, height, "Xiangqi");
  simp.set_render_target(win);
  xiangqi_startpos(*xiangqi);

  center_x = cast(float) width / 2.0;
  center_y = cast(float) height / 2.0;
  init_sound(win);
  init_textures();
  ui_init();
  ctrl_pressed := 0;

  while render_loop := true {
    dt = looptime_end - looptime_begin;
    looptime_begin = looptime_end;
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
          xiangqi_board_click(cast(float) mouse_x, cast(float) mouse_y, mouse_event, key_pressed);
        } else if e.key_code == .CTRL {
          ctrl_pressed = e.key_pressed;
        } else if e.key_pressed == 1 && e.key_code == #char "Z" && ctrl_pressed {
          gui_undo_move();
        } else if e.key_pressed == 1 && e.key_code == #char "Y" && ctrl_pressed {
          gui_redo_move();
        }
      }
    }

    render_xiangqiboard(cast(float)mouse_x, cast(float)mouse_y, mouse_event);
    render_ui();

    // sound effects.
    pre_entity_update(sound_player);
    for sound_player.streams  it.marked = true;
    post_entity_update(sound_player, dt);

    sleep_milliseconds(10);
    simp.swap_buffers(win);
    reset_temporary_storage();
    looptime_end = cast(float)get_time();
  }

  init_textures :: () #expand {
    success := simp.texture_load_from_file(*sprites, "data/xiangqi.png");
    assert(success);
  }

  xiangqi_board_click :: (x: float, y: float, mouse_event: bool, key_pressed: int) {
    board_margin := min(center_x, center_y) * .925;
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
      if xiangqi_mouse == {
      case XiangqiMouse.Idle;
        if key_pressed == 1 then {
          piece := xiangqi.board_9x10[row][col];
          if piece != 0 then {
            xiangqi_mouse = XiangqiMouse.Drag;
            generate_moves_for_piece(*xiangqi, *moves, row, col);
            filter_legal_moves(*xiangqi, *moves);
            from_index = index_of(row, col);
          }
        }

      case XiangqiMouse.Drag;
        to_index := index_of(row, col);
        if from_index != to_index then {
          piece := xiangqi.board_9x10[row_of(from_index)][col_of(from_index)];
          capture := xiangqi.board_9x10[row][col];
          move := Move32.{from_index, to_index, capture, piece};
          gui_make_move(move);
          xiangqi_mouse = XiangqiMouse.Idle;
          from_index = 0xFF;
          reset(*moves);
        } else {
          xiangqi_mouse = XiangqiMouse.Select;
        }

      case XiangqiMouse.Select;
        to_index := index_of(row, col);
        piece := xiangqi.board_9x10[row_of(from_index)][col_of(from_index)];
        capture := xiangqi.board_9x10[row][col];
        move := Move32.{from_index, to_index, capture, piece};
        gui_make_move(move);
        xiangqi_mouse = XiangqiMouse.Idle;
        from_index = 0xFF;
        reset(*moves);
      }
    } else {
      // outside of the board.
      xiangqi_mouse = XiangqiMouse.Idle; 
      from_index = 0xFF;
      reset(*moves);
    }
  }

  render_ui :: () #expand {
    text_theme: *Text_Input_Theme = *default_overall_theme.text_input_theme;
    time := get_time();
    ui_per_frame_update(win, width, height, time);
    k := height * 0.05;
    r := get_rect(5.0, height - 5.0 - k, 8.5*k, k);
    if button(r, "New Game") then {
      xiangqi_startpos(*xiangqi);
      prev_from = 0xFF;
      prev_to   = 0xFF;
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
    if base_checkbox(r, "Romanized", !chinese_pieces) then {
      chinese_pieces = !chinese_pieces;
    }
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
    action, str, state := text_input(r, "", text_theme);
    if action & .ENTERED {
      xiangqi_fen(*xiangqi, str);
      reset(state);
    }
  }

  render_xiangqiboard :: (mouse_x: float, mouse_y: float, mouse_event: bool) #expand {
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
    if show_moves == true then {
      for move: moves {
        to := move.to;
        render_possible_move(board_x, board_y, sq, to);
      }
    }

    if highlight_move == true then {
      if prev_from != 0xFF then {
        render_possible_move(board_x, board_y, sq, prev_from);
      }

      if prev_to != 0xFF then {
        render_possible_move(board_x, board_y, sq, prev_to);
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
      render_piece_drag(mouse_x, mouse_y, sq/2.0, sq, orient_piece(from_index), sprite_index, turn, color);
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
    if xiangqi_mouse == XiangqiMouse.Drag && from == orient_piece(from_index) then {
      return;
    }

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

  render_possible_move :: (board_x: float, board_y: float, sq: float, from: u8) {
    row, col := row_col_of(from);
    sprite_x := 3.0;
    piece := xiangqi.board_9x10[row][col];
    if piece != 0 then
      sprite_x -= 1.0;
    sprite_y := 0.0;


    row, col = row_col_of(orient_piece(from));

    index_x := cast(float) row;
    index_y := cast(float) col;
    gridx := board_x + index_x*sq; 
    gridy := board_y + index_y*sq;

    color := Vector4.{1.0, .55, 0.0, 0.75};

    uv0 := make_vector2(sprite_x*1.0/7.0, sprite_y*1.0/5.0);
    uv1 := make_vector2((sprite_x+1.0)*1.0/7.0, sprite_y*1.0/5.0);
    uv2 := make_vector2((sprite_x+1.0)*1.0/7.0, (sprite_y+1.0)*1.0/5.0);
    uv3 := make_vector2(sprite_x*1.0/7.0, (sprite_y+1.0)*1.0/5.0);

    // enlarge or make it smaller to make the move highlighting more aesthetically pleasing... 
    if piece != 0 then {
      immediate_quad(gridx - .05*sq, gridy - .05*sq, gridx + 1.05*sq, gridy + 1.05*sq, color, uv0, uv1, uv2, uv3);
    } else {
      immediate_quad(gridx + 0.25 * sq, gridy + 0.25 * sq, gridx + 0.75 * sq, gridy + 0.75 * sq, color, uv0, uv1, uv2, uv3);
    }
  }

  render_piece_drag :: (mousex: float, mousey: float, hsq: float, sq: float, from: u8, sprite_x: float, turn: s64, color: Vector4) {

    row, col := row_col_of(from);
    index_x := cast(float) row;
    index_y := cast(float) col;
    sprite_y := 2.0 - cast(float)turn;
    if chinese_pieces then
      sprite_y += 2.0;

    uv0 := make_vector2(sprite_x*1.0/7.0, sprite_y*1.0/5.0);
    uv1 := make_vector2((sprite_x+1.0)*1.0/7.0, sprite_y*1.0/5.0);
    uv2 := make_vector2((sprite_x+1.0)*1.0/7.0, (sprite_y+1.0)*1.0/5.0);
    uv3 := make_vector2(sprite_x*1.0/7.0, (sprite_y+1.0)*1.0/5.0);

    immediate_quad(mousex - hsq, mousey - hsq, mousex + hsq, mousey + hsq, color, uv0, uv1, uv2, uv3);

  }
}

#scope_file
width:  s32 = 680;
height: s32 = 480;
sprites: simp.Texture;
center_x: float = 0.0;
center_y: float = 0.0;
chinese_pieces := false;
orient := false;
dt: float = 0.0;
looptime_begin: float = 0;
looptime_end: float = 0;
xiangqi: Xiangqi;
moves: Moves;
sound: bool = true;

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
  reset(*moves);
  append(*moves, mov);
  gui_make_move(mov);
  reset(*moves);
  moves_made[moves_made_count] = next;
}

gui_make_move :: (move: Move32) {
  for m: moves {
    if m == move then {
      prev_from = move.from;
      prev_to   = move.to;
      make_move(*xiangqi, move);

      // add another move.
      assert (moves_made_count < moves_made.count);
      moves_made[moves_made_count] = move;
      moves_made_count += 1;

      sound_data: *Mixer_Sound_Data;
      if move.capture == 0 {
        sound_data = sound_quiet_move;
      } else {
        sound_data = sound_capture_move;
      }
      if sound == true then {
        play_sound(sound_data);
      }
      break;
    }
  }
}

XiangqiMouse :: enum {
  Idle;
  Drag;
  Select;
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
