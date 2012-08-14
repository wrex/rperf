require 'rperf'

describe Rperf::Workload do
  it "should require num_threads, blocksize, device_size, and type" do
    expect { Rperf::Workload.new }.to raise_error ArgumentError
    expect { Rperf::Workload.new(1) }.to raise_error ArgumentError
    expect { Rperf::Workload.new(1, 1024) }.to raise_error ArgumentError
    expect { Rperf::Workload.new(1, 1024, 4096) }.to raise_error ArgumentError
  end

  it "should accept 1 thread, 1024 blocksize, 4096 byte dev, and :seq_write" do
    expect { Rperf::Workload.new(1, 1024, 4096, :seq_write) }.not_to raise_error
  end

  it "should only accept valid IO types" do
    expect { Rperf::Workload.new(1, 1024, 4096, :foobar) }.to raise_error ArgumentError
  end

  describe "#next_block" do
    it "should return device size bytes for sequential writes with noloop" do
      wl = Rperf::Workload.new(1, 1024, 4096, :seq_write, :loop => false)
      bytes = 0
      while block = wl.next_block do
        bytes += block.length
      end
      bytes.should == 4096
    end

    # Yuck! No, no, no -- only do full blocks!
    it "should return partial last block with noloop" do
      wl = Rperf::Workload.new(1, 1024, 5000, :seq_write, :loop => false)
      4.times { wl.next_block.length.should == 1024 }
      wl.next_block.length.should == 5000 - 4096
      wl.next_block.should be nil
    end

    it "should write continuously with loop" do
      wl = Rperf::Workload.new(1,1024,5000, :seq_write, :loop => true)
      5.times { wl.next_block }
      wl.next_block.should_not be nil
    end
  end

end
