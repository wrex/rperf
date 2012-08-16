module Rperf
  class Worker
    attr_reader :blocksize
    attr_reader :device
    attr_reader :generator
    attr_reader :type
    attr_reader :order
    attr_reader :bytes_written

    attr_accessor :one_pass

    def initialize(device, blocksize=8192, type = :write,
                  order = :sequential, one_pass = true)
      @blocksize = blocksize
      @device = device
      @generator = BlockGenerator.new(blocksize)
      @type = type
      @order = order
      @one_pass = one_pass
      @bytes_written = 0
    end

    def loop? 
      not @one_pass
    end

    def run!
      while @bytes_written < device.size do 
        step!
      end
    end

    def step!
      if @bytes_written + blocksize <= device.size
        device.file.syswrite(generator.block)
        @bytes_written += blocksize
      elsif @one_pass
        raise EOFError
      else
        device.file.seek(0)
        device.file.syswrite(generator.block)
        @bytes_written += blocksize
      end
    end
  end
end

