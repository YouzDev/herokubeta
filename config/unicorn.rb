APP_PATH = "~/sharedfolder/testapp"

working_directory APP_PATH

stderr_path APP_PATH + "/log/unicorn.stderr.log"
stdout_path APP_PATH + "/log/unicorn.stderr.log"

pid APP_PATH + "/tmp/pids/unicorn.pid"
worker_processes 2
timeout 30
listen "127.0.0.1:3001", :tcp_nopush => true