require 'rperf'
require 'fileutils'
require 'digest'

describe Rperf::Seq_write do
  it "should require a pathname" do
    expect { Rperf::Seq_write.new }.to raise_error ArgumentError
  end

  it "should raise if pathname doesn't exist" do
    FileUtils.rm_rf("tmp/datafile")
    expect { Rperf::Seq_write.new("tmp/datafile", 1024) }.to raise_error ArgumentError
  end

  it "should completely fill file with random data" do
    # Create a sparse file exactly 10,240 bytes in size
    f = File.new("tmp/datafile", 'w')
    f.seek(10239)
    f.syswrite "\x00"
    f.close

    # Now fill it
    Rperf::Seq_write.new("tmp/datafile", 1024)

    # Verify it is still exactly 10,240 bytes in size
    File.size("tmp/datafile").should == 10_240

    # Now verify it contains 10 unique 1KB blocks
    sha1 = Digest::SHA1.new
    File.open("tmp/datafile", "r") do |f|
      seen = []
      10.times do
        hash = sha1.hexdigest f.sysread(1024)
        seen.should_not include(hash)
        seen << hash
      end
    end
  end

  it "should exactly fill a file with size not a multiple of blocksize" do
    # Create a sparse file exactly 1000 bytes in size
    f = File.new("tmp/datafile", 'w')
    f.seek(999)
    f.syswrite "\x00"
    f.close

    # Now fill it with a 64 byte block size
    Rperf::Seq_write.new("tmp/datafile", 64)

    File.size("tmp/datafile").should == 1_000
  end
end
