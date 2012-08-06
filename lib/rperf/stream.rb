module Rperf
  class Stream
    attr_reader :blocksize
    attr_reader :dedupe

    def initialize(bs=8192)
      self.blocksize = bs
      @random = Random.new(22069)
      @dedupe = 0 # no dedupe by default
    end

    def blocksize=(blocksize)
      # Note that 0.size returns the number of bytes in the FixNum representation of 0
      raise ArgumentError, "Invalid blocksize (must be a multiple of #{0.size})" unless
          blocksize % 0.size == 0

      @blocksize = blocksize
    end

    def block
      @last_block ||= @random.bytes(blocksize)

      if (100 - @dedupe) > (1 + @random.rand(100))
        # return a unique block
        @last_block = @random.bytes(blocksize)
      else
        # dupe'ing -- return the previous block
        @last_block
      end
    end

    def dedupe=(percentage)
      raise ArgumentError, "Expected a percentage from 0 to 100" unless 
          (0..100).include?(percentage)

      @dedupe = percentage
    end
  end
end
