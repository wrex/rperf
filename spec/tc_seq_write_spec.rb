require 'rperf'
require 'fileutils'
require 'digest'

describe Rperf::Seq_write do
  it "should require a pathname and blocksize" do
    expect { Rperf::Seq_write.new }.to raise_error ArgumentError
    FileUtils.touch("tmp/datafile")
    expect { Rperf::Seq_write.new("tmp/datafile") }.to raise_error ArgumentError
  end

  it "should raise if pathname doesn't exist" do
    FileUtils.rm_rf("tmp/datafile")
    expect { Rperf::Seq_write.new("tmp/datafile", 1024) }.to raise_error ArgumentError
  end

  it "should completely fill file with random data" do
    # Create a sparse file exactly 10,000 bytes in size
    f = File.new("tmp/datafile", 'w')
    f.seek(9999)
    f.syswrite "\x00"
    f.close

    # Now fill it
    Rperf::Seq_write.new("tmp/datafile", 1024)

    # Now verify it contains unique 1KB blocks
    sha1 = Digest::SHA1.new
    File.open("tmp/datafile", "r") do |f|
      seen = []
      while block = f.sysread(1024) do
        hash = sha1.hexdigest block
        seen.should_not include(hash)
        seen << hash
      end
    end
  end
end
