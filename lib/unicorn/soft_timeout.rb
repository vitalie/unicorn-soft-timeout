require 'unicorn/soft_timeout/version'

module Unicorn
  module SoftTimeout
    def self.new(app, soft_timeout = 12)
      ObjectSpace.each_object(Unicorn::HttpServer) do |s|
        s.extend(self)
        s.instance_variable_set(:@_soft_timeout, soft_timeout)
      end
      app # pretend to be Rack middleware since it was in the past
    end

    def process_client(client)
      worker_pid = Process.pid
      current_thread = Thread.current

      watcher = Thread.new do
        sleep(@_soft_timeout)
        logger.warn "#{self}: worker (pid: #{worker_pid}) exceeds soft timeout (limit: #{@_soft_timeout})"
        Process.kill :QUIT, worker_pid # graceful shutdown
        current_thread.raise Timeout::Error.new('Soft timeout exceeded')
      end

      super(client) # Unicorn::HttpServer#process_client
      watcher.terminate
    end
  end
end
