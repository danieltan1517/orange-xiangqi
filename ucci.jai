main :: () {
  path := copy_string(path_strip_filename(get_path_of_running_executable()));
  set_working_directory(path);
  print("%\n", path);
  // test program.
  process: Process;
  success := create_process(*process, tprint("%1%2", path, "pikafish"), capture_and_return_output=true, kill_process_if_parent_exits=true);
  defer deinit(*process);

  bytes_read: int;
  data := "uci\n";
  buf: [] u8;
  buf.data = data.data;
  buf.count = data.count;
  success, bytes_read = write_to_process(*process, buf);
  print("success := % %\n", success, bytes_read);
  sleep_milliseconds(1000);
  output_buffer := NewArray(4000, u8);
  error_buffer: [] u8;
  success, bytes_read = read_from_process(*process, output_buffer, error_buffer);
  str: string;
  str.data = output_buffer.data;
  str.count = bytes_read;
  print("(((%))), %\n", str, bytes_read);

  // some of them are "ucci", some are "uci"...
}

#import "Basic";
#import "Process";
#import "System"; // For get_path_of_running_executable.
#import "String"; // For path_strip_filename. 
