require "rperf/version"

module Rperf
  class Stream
    attr_accessor :blocksize

    def initialize(bs=8192)
      @blocksize ||= bs
      @random = Random.new(22069)
    end

    def block
      @random.bytes(blocksize)
    end
  end
end
