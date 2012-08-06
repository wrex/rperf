require 'rperf'

describe Rperf::Stream do
  let(:stream) { Rperf::Stream.new }

  it "should use 8 KiB as the default block size" do
    stream.blocksize.should == 8192
  end

  describe "#block" do
    it "should return exactly blocksize bytes" do
      stream.block.length.should == stream.blocksize
    end

    it "should return different results on each call" do
      block1 = stream.block
      stream.block.should_not == block1
    end
  end
end
