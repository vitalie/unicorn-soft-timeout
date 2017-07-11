require 'unicorn'
require 'unicorn/soft_timeout'
require 'minitest/autorun'
require 'minitest/unit'
require 'net/http'

STDIN.sync = STDOUT.sync = STDERR.sync = true

DEFAULT_TRIES = 100
DEFAULT_RES = 0.2

def redirect_test_io
  orig_err = STDERR.dup
  orig_out = STDOUT.dup
  STDERR.reopen("test_stderr.#{$$}.log", "a")
  STDOUT.reopen("test_stdout.#{$$}.log", "a")
  STDERR.sync = STDOUT.sync = true

  at_exit do
    File.unlink("test_stderr.#{$$}.log") rescue nil
    File.unlink("test_stdout.#{$$}.log") rescue nil
  end

  begin
    yield
  ensure
    STDERR.reopen(orig_err)
    STDOUT.reopen(orig_out)
  end
end

def wait_workers_ready(path, nr_workers)
  tries = DEFAULT_TRIES
  lines = []
  while (tries -= 1) > 0
    begin
      lines = File.readlines(path).grep(/worker=\d+ ready/)
      lines.size == nr_workers and return
    rescue Errno::ENOENT
    end
    sleep DEFAULT_RES
  end
  raise "#{nr_workers} workers never became ready:" \
        "\n\t#{lines.join("\n\t")}\n"
end

def hit(uris)
  results = []
  uris.each do |u|
    res = nil

    if u.kind_of? String
      u = 'http://127.0.0.1:8080/' if u == 'http://0.0.0.0:8080/'
      res = Net::HTTP.get(URI.parse(u))
    else
      url = URI.parse(u[0])
      res = Net::HTTP.new(url.host, url.port).start {|h| h.request(u[1]) }
    end

    assert res != nil, "Didn't get a response: #{u}"
    results << res
  end

  return results
end
