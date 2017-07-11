require 'test_helper'

include Unicorn

class TestHandler
  def call(env)
    while env['rack.input'].read(4096)
    end
    sleep 5
    [200, { 'Content-Type' => 'text/plain' }, ['hello!\n']]
  rescue Timeout::Error
    [200, { 'Content-Type' => 'text/plain' }, ['timeout!\n']]
  rescue Unicorn::ClientShutdown, Unicorn::HttpParserError => e
    $stderr.syswrite("#{e.class}: #{e.message} #{e.backtrace.empty?}\n")
    raise e
  end
end

class UnicornSoftTimeoutTest < Minitest::Test
  def setup
    @port = 5000
    @tester = TestHandler.new
    redirect_test_io do
      @server = Unicorn::HttpServer.new(@tester, listeners: ["127.0.0.1:#{@port}"])
      @tester = Unicorn::SoftTimeout.new(@tester, 3)
      @server.start
    end
  end

  def teardown
    redirect_test_io do
      wait_workers_ready("test_stderr.#$$.log", 1)
      File.truncate("test_stderr.#$$.log", 0)
      @server.stop(false)
    end
  end

  def test_simple_server
    results = hit(["http://localhost:#{@port}/test"])
    assert_equal 'timeout!\n', results[0], "Handler didn't really run"
  end
end
