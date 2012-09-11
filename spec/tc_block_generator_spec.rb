require 'rperf'
require 'digest'
require 'zlib'

describe Rperf::BlockGenerator do
  context "default" do
    its(:blocksize) { should eq(8192) }
    its("block.length") { should eq(8192) }
  end

  FIXNUM_BYTES = 0.size  # Number of bytes in a FIXNUM

  it "should not let me specify a blocksize that's not a multiple of the word size" do
    expect { Rperf::BlockGenerator.new(FIXNUM_BYTES - 1) }.to raise_error ArgumentError
  end
end

describe "#block" do
  subject(:generator) { Rperf::BlockGenerator.new(16) }

  its("block.length") { should eq(16) }

  it "should return different results on each call" do
    sha1 = Digest::SHA1.new
    seen = []

    100.times do
      hash = sha1.hexdigest(generator.block)
      expect(seen).to_not include(hash)
      seen << hash
    end
  end
end

describe "compression of a word-sized block" do

  subject(:gen) { Rperf::BlockGenerator.new(FIXNUM_BYTES) }

  its("block.length") { should eq(FIXNUM_BYTES) }

  case FIXNUM_BYTES

  when 4
    it "should return 3 of 4 bytes zeroed with compression=75" do
      gen.compression = 75
      expect(gen.block).to match(/^\x00\x00\x00[^\x00]$/)
    end

    it "should return 2 of 4 bytes zeroed with compression=50" do
      gen.compression = 50
      expect(gen.block).to match(/^\x00^\x00[^\x00][^\x00]$/)
    end

    it "should return 1 of 4 bytes zeroed with compression=25" do
      gen.compression = 25
      expect(gen.block).to match(/^\x00[^\x00][^\x00][^\x00]$/)
    end

  when 8
    it "should return 7 of 8 bytes zeroed with compression=90" do
      gen.compression = 90
      expect(gen.block).to match(/^\x00\x00\x00\x00\x00\x00\x00[^\x00]$/)
    end

    it "should return 4 of 8 bytes zeroed with compression=50" do
      gen.compression = 50
      expect(gen.block).to match(/^\x00\x00\x00\x00[^\x00][^\x00][^\x00][^\x00]$/)
    end

    it "should return 1 of 8 bytes zeroed with compression=20" do
      gen.compression = 20
      expect(gen.block).to match(/^\x00[^\x00][^\x00][^\x00][^\x00][^\x00][^\x00][^\x00]$/)
    end
  end
end

describe "#dedupe" do
  let(:generator) { Rperf::BlockGenerator.new(16) }

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

  it "block should return the same block approximately dedupe percent of the time" do
    percent = generator.dedupe = 81
    dupes = prevblock = 0
    1000.times do
      newblock = generator.block
      dupes += 1 if newblock == prevblock
      prevblock = newblock
    end

    # Give a fudge factor of +/- 5%
    (percent * 0.95 .. percent * 1.05).should include(dupes / 10.0)
  end
end

describe "#compression" do
  let(:generator) { Rperf::BlockGenerator.new(16) }

  it "should have a default compression factor of 0" do
    generator.compression.should == 0
  end

  it "should by default make each word in a block unique" do
    fullblock = Rperf::BlockGenerator.new.block

    # split block into an array of words
    # e.g. on 32-bit, "01234567" -> ["0123", "4567"]
    words = fullblock.scan(/.{#{FIXNUM_BYTES}}/)

    while word = words.shift do
      words.should_not include(word)
    end
  end

  it "should create uncompressible blocks by default" do
    block = Rperf::BlockGenerator.new.block
    compressed = Zlib::deflate(block)

    # note that compressing random data may increase size!
    compressed.length.should be >= block.length
  end

  it "should create ~2x compressible blocks with compression=50" do
    gen2 = Rperf::BlockGenerator.new 
    gen2.compression = 50
    uncompressed = gen2.block
    #10.times { uncompressed += gen2.block }
    compressed = Zlib::deflate(uncompressed)

    target = uncompressed.length / 2
    # check if within +/- 30% of target
    (target * 0.7 .. target * 1.3).should include(compressed.length)
  end
end
