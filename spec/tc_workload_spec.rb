require 'rperf'

describe Rperf::Workload do
  it "should require a workload type and device size" do
    expect { Rperf::Workload.new }.to raise_error ArgumentError
    expect { Rperf::Workload.new(:seq_read) }.to raise_error ArgumentError
  end

  it "should accept a valid workload type" do
    expect { Rperf::Workload.new(:seq_read, "/tmp/foo") }.not_to raise_error
  end

  it "should only accept valid IO types" do
    expect { Rperf::Workload.new(:foobar, "/tmp/foo") }.to raise_error ArgumentError
  end

  describe "#next" do
    it "should return device size bytes for sequential writes" do
      wl = Rperf::Workload.new(:seq_write, "0 KiB", 
                               :threads => 1,
                               :blocksize => "1 KiB"
                               :loop => 0)
      bytes = 0
      while block = wl.next do
        bytes += block.length
      end
    end
  end

end
