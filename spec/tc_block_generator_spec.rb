require 'rperf'
require 'digest'
require 'zlib'

# Number of bytes in a FIXNUM, AKA "word size"
FIXNUM_BYTES = 0.size

describe Rperf::BlockGenerator do

  it "should not let me specify a blocksize that's not a multiple of the word size" do
    expect { Rperf::BlockGenerator.new(FIXNUM_BYTES - 1) }.to raise_error ArgumentError
  end

  context "default" do
    its(:blocksize) { should eq(8192) }
    its("block.length") { should eq(8192) }
  end

  describe "16 byte block generator" do
    subject(:generator) { Rperf::BlockGenerator.new(16) }

    its("block.length") { should eq(16) }

    it "should return unique blocks" do
      sha1 = Digest::SHA1.new
      seen = []

      100.times { seen << sha1.hexdigest(generator.block) }
      expect(seen.uniq.length).to eq(seen.length)
    end
  end
end

describe "16 byte block dedupe" do
  subject(:generator) { Rperf::BlockGenerator.new(16) }

  it "should accept a dedupe percentage of 0" do
    expect { generator.dedupe = 0 }.not_to raise_error
  end

  it "should accept a dedupe percentage of 100" do
    expect { generator.dedupe = 100 }.not_to raise_error
  end

  it "should not accept a dedupe percentage > 100" do
    expect { generator.dedupe = 101 }.to raise_error
  end

  it "should not accept a dedupe percentage < 0" do
    expect { generator.dedupe = -1 }.to raise_error
  end

  it "should return the same block approximately dedupe percent of the time" do
    percent = generator.dedupe = 66
    dupes = prevblock = 0
    1000.times do
      newblock = generator.block
      dupes += 1 if newblock == prevblock
      prevblock = newblock
    end

    # Give a fudge factor of +/- 5%
    expect(percent * 0.95 .. percent * 1.05).to include(dupes / 10.0)
  end
end

describe "word-sized block compression" do

  subject(:generator) { Rperf::BlockGenerator.new(FIXNUM_BYTES) }

  its("block.length") { should eq(FIXNUM_BYTES) }

  case FIXNUM_BYTES

  when 4
    it "should return 3 of 4 bytes zeroed with compression=75" do
      generator.compression = 75
      expect(generator.block).to match(/^\x00{3}[^\x00]$/)
    end

    it "should return 2 of 4 bytes zeroed with compression=50" do
      generator.compression = 50
      expect(generator.block).to match(/^\x00{2}[^\x00]{2}$/)
    end

    it "should return 1 of 4 bytes zeroed with compression=25" do
      generator.compression = 25
      expect(generator.block).to match(/^\x00[^\x00]{3}$/)
    end

  when 8
    it "should return 7 of 8 bytes zeroed with compression=90" do
      generator.compression = 90
      expect(generator.block).to match(/^\x00{7}[^\x00]$/)
    end

    it "should return 4 of 8 bytes zeroed with compression=50" do
      generator.compression = 50
      expect(generator.block).to match(/^\x00{4}[^\x00]{4}/)
    end

    it "should return 1 of 8 bytes zeroed with compression=20" do
      generator.compression = 20
      expect(generator.block).to match(/^\x00[^\x00]{7}/)
    end
  else
    raise "Unexpected number of bytes in a FIXNUM!"
  end
end

describe "8 KiB block compression" do
  let(:generator) { Rperf::BlockGenerator.new }
  subject(:fullblock) { generator.block }

  context "default (no compression)" do

    it "has compression level of 0" do
      expect(generator.compression).to eq(0)
    end

    it "should make each word in a block unique" do
      # split block into an array of words
      # e.g. on 32-bit, "01234567" -> ["0123", "4567"]
      words = fullblock.scan(/.{#{FIXNUM_BYTES}}/)

      expect(words.uniq.length).to eq(words.length)
    end

    it "should create uncompressible blocks" do
      compressed = Zlib::deflate(fullblock)

      # note that compressing random data may increase size!
      expect(compressed.length).to be >= fullblock.length
    end
  end

  context "with compression=50" do
    it "should create ~2x compressible blocks" do
      generator.compression = 50
      uncompressed = generator.block
      compressed = Zlib::deflate(uncompressed)

      target = uncompressed.length / 2
      # check if within +/- 30% of target
      (target * 0.7 .. target * 1.3).should include(compressed.length)
    end
  end
end
