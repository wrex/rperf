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

end
