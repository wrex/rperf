require 'rperf'
require 'digest'

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

  let(:device) { Rperf::Device.new("tmp/datafile", "32 KiB") }

  let(:worker) { Rperf::Worker.new(device) }

  it "should default to 8KiB blocksize" do
    worker.generator.blocksize.should == 8192
  end

  it "should default to non-looping" do
    worker.loop?.should be false
  end

  it "should default to write" do
    worker.type.should == :write
  end

  it "should default to sequential ordering" do
    worker.order.should == :sequential
  end

  it "should write one block when step is called" do
    worker.bytes_written.should == 0
    worker.step!
    worker.bytes_written.should == 8192
    worker.device.file.size.should == 8192
  end

  it "should by fill a file with random data when run is called" do
    worker.device.file.size.should == 0
    worker.run!
    verify_unique_contents("tmp/datafile", 8192).should == 32768
    worker.device.file.size.should == 32768
  end

  it "should only let step be called four times on 32K file"  do 
    4.times { worker.step! }
    expect { worker.step! }.to raise_error EOFError
  end

  it "should allow writing more than file length if looping" do 
    worker.one_pass = false
    4.times { worker.step! }
    expect { worker.step! }.not_to raise_error
    worker.bytes_written.should == 32768 + 8192
  end
    
  it "should write blocks in random order when type is write and selector is random"
  it "should loop sequentially when told to"
  it "should only do io to the specified range"

end

