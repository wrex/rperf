module Rperf
  class Workload
  end

  class SequentialWriter < Workload
    attr_reader :file
    attr_reader :blocksize
    attr_reader :end_offset
    attr_reader :workers

    attr_accessor :start_offset
    attr_accessor :threads
    attr_accessor :device
    attr_accessor :type
    attr_accessor :order
    attr_accessor :loop

    def initialize(pathname, size_or_start, end_offset = nil)
      @pathname = pathname

      if end_offset 
        start_offset = Rperf.normalize_units(size_or_start)
      else
        start_offset = 0
        end_offset = Rperf.normalize_units(size_or_start)
      end

      # default values
      @start_offset = start_offset
      @pos = @start_offset
      @end_offset = end_offset
      @blocksize = 8192
      @type = :write
      @order = :sequential
      @loop = false
      @workers = [ Rperf::Worker.new(self) ]
      @threads = 1

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

    def threads=(n)
      @threads = n
      @workers = []
      n.times { @workers << Rperf::Worker.new(self) }
    end
  end
end

