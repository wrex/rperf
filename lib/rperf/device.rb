module Rperf
  class Device
    attr_reader :pathname
    attr_reader :size
    attr_reader :file

    def initialize(pathname, size)
      @pathname = pathname
      @size = size
      @file = File.open(pathname, "w+")
      # TODO: verify device is at least as big as size
    end
  end
end
