require "rperf/version"
require "rperf/stream"
require "rperf/workload"

module Rperf
  def Rperf::normalize_units(str)

    case str

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
      return 0

    end
  end
end
