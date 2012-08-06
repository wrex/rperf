require "rperf/version"

module Rperf
  class Stream
    attr_accessor :blocksize
    attr_reader :dedupe

    def initialize(bs=8192)
      @blocksize ||= bs
      @random = Random.new(22069)
      @dedupe = 0 # no dedupe by default
    end

    def block
      @lastblock ||= @random.bytes(blocksize)

      if (1 + @random.rand(100)) <= (100 - @dedupe)
        @last_block = @random.bytes(blocksize)
      end

      @last_block
    end

    def dedupe= (percentage)
      raise unless (0..100).include?(percentage)
      @dedupe = percentage
    end
  end

  class Workload
    def initialize(type, path, *opts)

      raise ArgumentError, "Invalid workload type" unless
               [:seq_read, :seq_write, :rand_read, :rand_write, :rand_both].include?(type) 

    end
  end
end
