require 'rperf'

describe Rperf::Stream do
  let(:stream) { Rperf::Stream.new(16) }

  it "should use 8 KiB as the default block size" do
    str2 = Rperf::Stream.new
    str2.blocksize.should == 8192
  end

  it "should only let me use a multiple of the word size as blocksize" do
    expect { Rperf::Stream.new(7) }.to raise_error ArgumentError
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

  describe "#dedupe" do
    it "should accept a dedupe percentage of 0" do
      expect { stream.dedupe = 0 }.not_to raise_error
    end

    it "should accept a dedupe percentage of 100" do
      expect { stream.dedupe = 100 }.not_to raise_error
    end

    it "should not accept a dedupe percentage > 100" do
      expect { stream.dedupe = 101 }.to raise_error
    end

    it "should not accept a dedupe percentage < 0" do
      expect { stream.dedupe = -1 }.to raise_error
    end

    it "block should return the same block approximately dedupe percent of the time" do
      stream.dedupe = 75
      dupes = prevblock = 0
      100.times do
	newblock = stream.block
	dupes += 1 if newblock == prevblock
	prevblock = newblock
      end
      dupes.should be >= (stream.dedupe * 0.9).to_i
      dupes.should be <= (stream.dedupe * 1.1).to_i
    end
  end
end
