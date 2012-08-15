require 'rperf'
require 'digest'

# Device
#       @size (in bytes)
#       @file (File object)
#       @workers (could be reader, writer, or readwriter)
#
# Worker
#       @blocksize
#       @device
#       @device_range
#       @type (read, write, or both)
#       @offset_selector (sequential, random, or sequential_loop)
#       @block_generator
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

describe Rperf::Worker do
  it "should require a Device" do
    expect { Rperf::Worker.new() }.to raise_error ArgumentError
  end

  it "should default to writing sequentially, 8KiB blocksize, random data, no loop " do
    dev = Rperf::Device.new("tmp/datafile", 32768)
    worker = Rperf::Worker.new(dev)
    worker.blocksize.should == 8192
    worker.run!
    verify_unique_contents("tmp/datafile", 8192).should == 32768
  end

  it "should write blocks in random order when type is write and selector is random"
  it "should loop sequentially when told to"
  it "should only do io to the specified range"
end

