module Rperf
  class DeviceStats
    attr_accessor :bytes_written

    def initialize
      @bytes_written = 0
    end
  end
end
