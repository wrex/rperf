module Rperf
  class Workload
    def initialize(type, path, *opts)

      raise ArgumentError, "Invalid workload type" unless
               [:seq_read, :seq_write, :rand_read, :rand_write, :rand_both].include?(type) 

    end
  end
end
