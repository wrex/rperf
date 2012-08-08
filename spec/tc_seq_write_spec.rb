require 'rperf'
require 'fileutils'

describe Rperf::Seq_write do
  it "should require a pathname" do
    expect { Rperf::Seq_write.new }.to raise_error ArgumentError
  end

  it "should raise if pathname doesn't exist" do
    FileUtils.rm_rf("tmp/datafile")
    expect { Rperf::Seq_write.new("/tmp/datafile") }.not_to raise_error
  end

  it "should completely fill file with random data"

end
