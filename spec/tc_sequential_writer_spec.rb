require 'rperf'
require 'digest'
require 'fileutils'

describe Rperf::SequentialWriter do
  DATAFILE = "tmp/datafile"
  NOSUCHFILE = "tmp/nosuchfile"

  before(:each) { FileUtils.touch DATAFILE }
  after(:each) { FileUtils.rm DATAFILE }
  after(:all) { FileUtils.rm NOSUCHFILE }

  it "should require a device" do
    expect { Rperf::SequentialWriter.new() }.to raise_error ArgumentError
  end

  it "should require a device and size" do ||
    expect { Rperf::SequentialWriter.new(DATAFILE) }.to raise_error ArgumentError
    expect { Rperf::SequentialWriter.new(DATAFILE, "32 KiB") }.not_to raise_error
  end

  it "should raise for an invalid device" do
    FileUtils.chmod 0000, DATAFILE
    expect { Rperf::SequentialWriter.new(DATAFILE, "32 KiB") }.to raise_error Errno::EACCES
  end

  it "should let you specify device, start offset, and device offset" do
    expect { @writer = Rperf::SequentialWriter.new(DATAFILE, 8192, 32768) }.not_to raise_error
    expect(@writer.size).to eq(32768 - 8192)
    expect(@writer.start_offset).to eq(8192)
    expect(@writer.end_offset).to eq(32768)
  end

  it "should also let you specify just the device and size" do
    expect { @writer = Rperf::SequentialWriter.new(DATAFILE, "32 KiB") }.not_to raise_error
    expect(@writer.size).to eq(32768)
    expect(@writer.start_offset).to eq(0)
    expect(@writer.end_offset).to eq(32768)
  end

  it "should not create a file" do
    expect { Rperf::SequentialWriter.new(NOSUCHFILE, "8KiB", "32KiB") }.to raise_error
  end

end

describe "Writing to a 32KiB range" do

  before(:each) { FileUtils.touch DATAFILE }
  after(:each) { FileUtils.rm DATAFILE, :force => true }

  subject(:writer) { Rperf::SequentialWriter.new(DATAFILE, "32 KiB") }

  context "default" do
    its(:blocksize) { should eq(8192) }
    it { should_not be_loop }
    its('device.bytes_written') { should eq(0) }
    its('device.bytes_read') { should eq(0) }

    it "should write one block when step is called" do
      writer.step!
      expect(writer.device.bytes_written).to eq(8192)

      # TODO: need expectation to verify a block was actually written
      # to the DATAFILE
    end
  end

  context "looping specified" do
    before(:each) { writer.loop!}

    it { should be_loop }
  end



  xit "should by fill a file with random data when run is called" do
    workload.device.file.size.should == 0

    workload.workers[0].run!

    sha1 = Digest::SHA1.new
    seen = []
    File.open("tmp/datafile", "r") do |f|
      hash = sha1.hexdigest(f.sysread(workload.blocksize))
      seen.should_not include(hash)
      seen << hash
    end
    workload.device.file.size.should == 32768
  end

  xit "should create one worker for each thread" do
    workload.threads = 4
    workload.workers.size.should == 4
  end

  xit "should fill a file with random data with multiple workers" do
    pending "Gotta figure out how to parcel up the work"
  end

  xit "should only let step be called four times on 32K file"  do 
    4.times { workload.step! }
    expect { workload.step! }.to raise_error EOFError
  end

  xit "should allow writing more than file length if looping" do 
    workload.one_pass = false
    4.times { workload.step! }
    expect { workload.step! }.not_to raise_error
    workload.bytes_written.should == 32768 + 8192
  end
    
  xit "should write blocks in random order when type is write and selector is random"
  xit "should loop sequentially when told to"
  xit "should only do io to the specified range"

end

