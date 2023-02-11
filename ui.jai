main :: () {

  path = copy_string(path_strip_filename(get_path_of_running_executable()));
  set_working_directory(path);
  set_default_theme(default_theme_procs[Default_Themes.Grayscale]());
  win := create_window(width, height, "Xiangqi");
  simp.set_render_target(win);
  xiangqi_startpos(*xiangqi);
  reset(*moves);
  generate_moves(*xiangqi, *moves);
  filter_legal_moves(*xiangqi, *moves);

  center_x = cast(float) width / 2.0;
  center_y = cast(float) height / 2.0;
  init_sound(win);
  init_textures();
  ui_init();
  ctrl_pressed := 0;


  engine, tf := load_engine("ucci");
  assert(tf);
  defer close_engine(*engine);

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

    if moves.count then
      update_ucci(*engine);

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
    success  = simp.texture_load_from_file(*setting_sprite, "data/settings.png");
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
      }
    } else {
      // outside of the board.
      xiangqi_mouse = XiangqiMouse.Idle; 
      from_index = 0xFF;
    }
  }

  render_ui :: () #expand {
    text_theme  := *default_overall_theme.text_input_theme;
    label_theme := *default_overall_theme.label_theme;
    time := get_time();
    ui_per_frame_update(win, width, height, time);
    k := clamp(height * 0.05, 15.0, 45.0);
    r := get_rect(5.0, height - 5.0 - k, k, k);

    if button(r, "", texture=*setting_sprite) then {
      display_settings = !display_settings;
    }

    if display_settings {
      r.x += 20.0;
      r.y -= 5.0;
      r.w = 8.5 * k;
      color := Vector4.{.1, .1, .1, .75};
      simp.set_shader_for_color(true);
      simp.immediate_quad(17.0, r.y, r.x + r.w + 7.0, r.y - 14*k, color);

      r.y -= k + 10.0;
      if button(r, "New Game") then {
        status_string = "";
        xiangqi_startpos(*xiangqi);
        moves_made_count = 0;
        reset(*moves);
        memset(*moves_made, 0, size_of(type_of(moves_made)));
        generate_moves(*xiangqi, *moves);
        filter_legal_moves(*xiangqi, *moves);
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
        fen_string = copy_string(str);
        reset(state);
      }
     
      r.y -= k + 5.0;
      if base_checkbox(r, "Red", red_ai) then {
        red_ai = !red_ai;
      }
     
      r.y -= k + 5.0;
      if base_checkbox(r, "Black", black_ai) then {
        black_ai = !black_ai;
      }
    }
     
    if status_string {
      r = get_rect(5.0, 5.0, 8.5*k, k);
      label(r, status_string, label_theme);
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
      render_piece_drag(mouse_x, mouse_y, sq/2.0, sq, orient_piece(from_index), sprite_index, turn, color);
    }
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

  render_possible_move :: (board_x: float, board_y: float, sq: float, from: u8, color: Vector4) {
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
setting_sprite: simp.Texture;
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
  gui_make_move(mov);
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
      reset(*moves);
      generate_moves(*xiangqi, *moves);
      filter_legal_moves(*xiangqi, *moves);
      status_string = "";
      if moves.count == 0 then {
        status_string = "Checkmate.";  
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

Engine :: struct {
  process: Process;
  state: EngineState;
  timer: float;
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

load_engine :: (name: string) -> Engine, bool {
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
  return engine, success;
}

update_ucci :: (engine: *Engine) {
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
    for msg, index: split(messages, NEWLINE) {
      message := msg;
      if message
        print("%\n", message);
      if equal(message, "ucciok") then {
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
      if message
        print("%\n", message);
      if equal(message, "readyok") then {
        state = .uccinewgame;
        engine.timer = FLOAT32_INFINITY;
      } 
    }
  case .uccinewgame;
    state = .idle;
  case .idle;
    if is_engine_turn() then {
      state = .go;
      engine.timer = FLOAT32_INFINITY;
    }
  case .go;
    state = .bestmove;
  case .bestmove;
    if !is_engine_turn() then {
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
        if message
          print("%\n", message);
        if starts_with(message, "bestmove ") then {
          parse_token(*message);
          message = eat_spaces(message);
          mov_token := parse_token(*message);
          mov := to_move32(*xiangqi, mov_token);
          gui_make_move(mov);
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
      write_to_process(process, to_u8_array("ucci\n"));
      engine.timer = 0.0;
    } 
  case .isready;
    if engine.timer > 5.0 then {
      write_to_process(process, to_u8_array("isready\n"));
      engine.timer = 0.0;
    } 
  case .uccinewgame;
    if engine.timer > 5.0 then {
      write_to_process(process, to_u8_array("uccinewgame\n"));
      engine.timer = 0.0;
    }
  case .idle;
    engine.timer = FLOAT32_INFINITY;
  case .go;
    str := get_ucci_position();
    print("%\n", str);
    gostr := "go depth 3\n";
    write_to_process(process, to_u8_array(str));
    sleep_milliseconds(10); // TODO: bad hack...
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

display_settings := false;

red_ai: bool = false;
black_ai: bool = false;

is_engine_turn :: () -> bool {
  if xiangqi.turn == 0 && red_ai == true then
    return true;
  if xiangqi.turn == 1 && black_ai == true then
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
