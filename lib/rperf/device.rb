module Rperf
  class Device
    attr_reader :pathname
    attr_reader :file

    attr_accessor :stats

    def initialize(pathname)
      @pathname = pathname
      @file = File.open(pathname, "w+")
      @stats = Rperf::DeviceStats.new
    end
  end
end
