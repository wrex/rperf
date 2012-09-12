module Rperf
  class WorkerThread
    attr_reader :file
    attr_reader :blocksize
    attr_reader :end_offset

    attr_accessor :start_offset
    attr_accessor :device

    def initialize(pathname, size_or_start, end_offset = nil)
      @pathname = pathname

      if end_offset 
        start_offset = Rperf.normalize_units(size_or_start)
      else
        start_offset = 0
        end_offset = Rperf.normalize_units(size_or_start)
      end

      @start_offset = start_offset
      @pos = @start_offset
      @end_offset = end_offset
      @blocksize = 8192
      @loop = false
      @device = Rperf::Device.new(@pathname)
    end

    def start_offset=(offset)
      @start_offset = Rperf.normalize_units(offset)
      # TODO: need to seek(@start_offset)
    end

    def end_offset=(offset)
      @end_offset = Rperf.normalize_units(offset)
    end

    def size
      @end_offset ? @end_offset - @start_offset : nil
    end
  end

  class SequentialWriter < WorkerThread
    def initialize(pathname, *args)
      super(pathname, *args)
    end

    def loop?
      @loop
    end

    def loop!
      @loop = true
    end

    def no_loop!
      @loop = false
    end

    def step!
      device.bytes_written += blocksize
    end
  end
end

