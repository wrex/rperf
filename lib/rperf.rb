require "rperf/version"
require "rperf/block_generator"
require "rperf/device"
require "rperf/worker"

module Rperf
  def normalize_units(val)

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
  
  module_function :normalize_units
end
