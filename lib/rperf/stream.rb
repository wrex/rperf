module Rperf
  class Stream
    attr_reader :blocksize
    attr_reader :dedupe
    attr_reader :compression

    # Note that 0.size returns the number of bytes in the FixNum representation of 0
    WORD_SIZE = 0.size

    def initialize(bs=8192)
      self.blocksize = bs
      @random = Random.new(22069)
      @dedupe = 0 # no dedupe by default
      @compression = 0 # not compressible by default
      @last_block = make_block
    end

    def block
      if (100 - @dedupe) > (1 + @random.rand(100))
        # return a unique block
        @last_block = make_block
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

    def compression=(percentage)
      raise ArgumentError, "Expected a percentage from 0 to 100" unless 
          (0..100).include?(percentage)

      @compression = percentage
    end
  private

    def blocksize=(blocksize)
      raise ArgumentError, "Invalid blocksize (must be a multiple of #{WORD_SIZE})" unless
          blocksize % 0.size == 0

      @blocksize = blocksize
    end

    def make_block
      # compression contains percentage of bytes in block to zero
      # calculate n as the number of bytes in a word to zero
      n = (WORD_SIZE * compression.to_f / 100).to_i
      zeroes = "\x00" * n

      block = ""
      (blocksize / WORD_SIZE).times do
        next_word = @random.bytes(WORD_SIZE)
        if compression > 0
          next_word[0..n-1] = zeroes
        end
        block += next_word
      end

      block
    end

  end
end
