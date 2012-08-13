require "rperf/version"
require "rperf/block_generator"
require "rperf/workload"

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

  def Rperf::normalize_units(val)

    case val

    when /^\s*(\d+)\s*KiB\s*$/i
      return $1.to_i * 1024

    when /^\s*(\d+)\s*KB\s*$/i
      return $1.to_i * 1000

    when /^\s*(\d+)\s*MB\s*$/i
      return $1.to_i * 1_000_000

    when /^\s*(\d+)\s*GB\s*$/i
      return $1.to_i * 1_000_000_000

    when /^\s*(\d+)\s*TB\s*$/i
      return $1.to_i * 1_000_000_000_000

    when /^\s*(\d+)\s*MiB\s*$/i
      return $1.to_i * 1024 * 1024

    when /^\s*(\d+)\s*GiB\s*$/i
      return $1.to_i * 1024 * 1024 * 1024

    when /^\s*(\d+)\s*TiB\s*$/i
      return $1.to_i * 1024 * 1024 * 1024 * 1024

    when /^\s*(\d+)\s*$/
      return $1.to_i

    else
      return val

    end
  end
end
