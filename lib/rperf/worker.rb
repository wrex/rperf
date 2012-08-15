module Rperf
  class Worker
    attr_reader :blocksize
    attr_reader :device
    attr_reader :generator

    def initialize(device, blocksize=8192)
      @blocksize = blocksize
      @device = device
      @generator = BlockGenerator.new(blocksize)
    end

    def run!
      written = 0
      while written < device.size do 
        device.file.syswrite(generator.block)
        written += blocksize
      end
    end
  end
end

