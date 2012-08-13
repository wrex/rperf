module Rperf
  class Seq_write
    def initialize(pathname, blocksize=8192)

      raise ArgumentError, "File doesn't exist! (#{pathname})" unless File.exist?(pathname)

      device_size = File.size(pathname)

      stream = Rperf::BlockGenerator.new(blocksize)

      f = File.open(pathname, "w")
      written = 0
      while written < device_size do
        if device_size - written >= blocksize
          f.syswrite(stream.block)
        else
          n = device_size - written - 1
          f.syswrite(stream.block[0..n])
        end
        written += blocksize
      end
    end
  end
end
