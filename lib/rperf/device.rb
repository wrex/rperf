module Rperf
  class Device
    attr_reader :pathname
    def initialize(pathname)
      @pathname = pathname
    end
  end
end
