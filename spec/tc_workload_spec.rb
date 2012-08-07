require 'rperf'

describe Rperf::Workload do
  it "should require num_threads, blocksize, device_size, and type" do
    expect { Rperf::Workload.new }.to raise_error ArgumentError
    expect { Rperf::Workload.new(1) }.to raise_error ArgumentError
    expect { Rperf::Workload.new(1, 1024) }.to raise_error ArgumentError
    expect { Rperf::Workload.new(1, 1024, 4096) }.to raise_error ArgumentError
  end

  it "should accept 1-1024-W to a 4096 byte device" do
    expect { Rperf::Workload.new(1, 1024, 4096, :seq_write) }.not_to raise_error
  end

  it "should only accept valid IO types" do
    expect { Rperf::Workload.new(1, 1024, 4096, :foobar) }.to raise_error ArgumentError
  end

  describe "#next" do
    it "should return device size bytes for sequential writes" do
      wl = Rperf::Workload.new(1, 1024, 4096, :seq_write, :loop => false)
      bytes = 0
      while block = wl.next_block do
        bytes += block.length
      end
      bytes.should == 4096
    end
  end

end
