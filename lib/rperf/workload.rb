module Rperf
  class Workload
    def initialize(threads, blocksize, device_size, type, opts = {})

      raise ArgumentError, "Invalid workload type" unless
               [:seq_read, :seq_write, :rand_read, :rand_write, :rand_both].include?(type) 

      @stream = Rperf::BlockGenerator.new(blocksize)
      @returned_bytes = 0
      @device_size = device_size

      @loop = opts[:loop]
    end

    def next_block
      block = @stream.block
      remaining = @device_size - @returned_bytes
      if remaining == 0
        return nil unless @loop
	# looping
	@returned_bytes = block.length
	return block
      elsif remaining > block.length
        @returned_bytes += block.length
        return block
      else
        @returned_bytes += remaining
        return block.slice(0, remaining)
      end
    end

  end
end
