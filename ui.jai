#import "Window_Creation";
#import "System";
#import "Basic";
simp :: #import "Simp";
#import "Input";

main :: () {
  window_width  : s32 = 1920;
  window_height : s32 = 1080;
  render_width  : s32 = 1920;
  render_height : s32 = 1080;

  win := create_window(window_width, window_height, "Xiangqi");
  simp.set_render_target(win);
  quit := false;
  while !quit {
    update_window_events();
    for get_window_resizes() {
        if it.window == win {
            window_width  = it.width;
            window_height = it.height;
            render_width  = window_width;
            render_height = window_height;
            simp.update_window(win);
        }
    }

    simp.clear_render_target(0.15555, 0.15555, 0.15555, 1.0);
    for events_this_frame {
        if it.type == .QUIT then 
          quit = true;
    }

    sleep_milliseconds(10);
    simp.swap_buffers(win);
    reset_temporary_storage();
  }
}
