module Rperf
  class Device
    attr_reader :pathname
    attr_reader :file

    def initialize(pathname)
      @pathname = pathname
      raise unless File.exists?(pathname)
      @file = File.open(pathname, "w+")
      @stats = Hash.new(0)
    end

    def bytes_written
      @stats[:bytes_written]
    end

    def bytes_written=(value)
      @stats[:bytes_written] = value
    end

    def bytes_read
      @stats[:bytes_read]
    end

    def bytes_read=(value)
      @stats[:bytes_read] = value
    end
  end
end
