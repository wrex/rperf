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

  def create_sparse_file(name,size)
    f = File.new(name, 'w')
    f.seek(size - 1)
    f.syswrite "\x00"
    f.close
  end

  def get_a_block(fh, blocksize)
    begin
      return block = fh.sysread(blocksize)
    rescue EOFError
      return false
    end
  end

  def verify_unique_contents(name, blocksize)
    sha1 = Digest::SHA1.new
    bytes_read = 0
    File.open(name, "r") do |f|
      seen = []
      while block = get_a_block(f, blocksize) do
        bytes_read += block.length
        hash = sha1.hexdigest block
        seen.should_not include(hash)
        seen << hash
      end
    end
    return bytes_read
  end

  it "should completely fill a file with random data" do
    filesize = 100_000
    blocksize = 1_024
    create_sparse_file("tmp/datafile", filesize)
    Rperf::Seq_write.new("tmp/datafile", blocksize)
    File.size("tmp/datafile").should == filesize
    verify_unique_contents("tmp/datafile", blocksize).should == filesize
  end

  it "should exactly fill a file with size not a multiple of blocksize" do
    filesize = 1_000
    blocksize = 64
    create_sparse_file("tmp/datafile", filesize)
    Rperf::Seq_write.new("tmp/datafile", blocksize)
    File.size("tmp/datafile").should == filesize
  end
end
