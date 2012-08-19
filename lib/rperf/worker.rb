module Rperf
  class Worker

    def initialize(workload)
      @workload = workload
      @generator = BlockGenerator.new(@workload.blocksize)
    end

    def device
      @workload.device
    end

    def stats
      @workload.device.stats
    end

    def size
      @workload.size
    end

    def blocksize
      @workload.blocksize
    end

    def file
      @workload.device.file
    end

    def run!
      while device.stats.bytes_written < size do 
        step!
      end
    end

    def step!
      if stats.bytes_written + blocksize <= size
        file.syswrite(@generator.block)
        stats.bytes_written += blocksize
      elsif @workload.loop
        device.file.seek(@workload.start_offset)
        device.file.syswrite(generator.block)
        stats.bytes_written += blocksize
      else
        raise EOFError
      end
    end
  end
end

