require 'rperf'
require 'zlib'

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

  describe "#compression" do
    it "should have a default compression factor of 0" do
      stream.compression.should == 0
    end

    it "should by default make each word in a block unique" do
      wordsize = 0.size
      fullblock = Rperf::Stream.new.block

      # split block into an array of words
      # e.g. on 32-bit, "01234567" -> ["0123", "4567"]
      words = fullblock.scan(/.{#{wordsize}}/)

      while word = words.shift do
        words.should_not include(word)
      end
    end

    it "should create uncompressible blocks by default" do
      block = Rperf::Stream.new.block
      compressed = Zlib::deflate(block)
      
      # note that compressing random data may increase size!
      compressed.length.should be >= block.length
    end

    it "should create ~2x compressible blocks with compression=50" do
      str2 = Rperf::Stream.new 
      str2.compression = 50
      block = str2.block
      compressed = Zlib::deflate(block)

      compressed.length.should be >= str2.blocksize / 2 * 0.9
      compressed.length.should be <= str2.blocksize / 2 * 1.1
    end

  end
end
