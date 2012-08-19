require 'rperf'
require 'digest'
require 'fileutils'

describe Rperf::Workload do

  it "should require a device" do
    expect { Rperf::Workload.new() }.to raise_error ArgumentError
  end

  it "should require a device and size" do ||
    FileUtils.touch("tmp/datafile")
    expect { Rperf::Workload.new("tmp/datafile") }.to raise_error ArgumentError
    expect { Rperf::Workload.new("tmp/datafile", "32 KiB") }.not_to raise_error
  end

  it "should not let you specify a bogus device" do
    expect { Rperf::Workload.new("/bogusdevice", "32 KiB") }.to raise_error
  end

  it "should let you specify device, start, and end" do ||
    FileUtils.touch("tmp/datafile")
    expect { Rperf::Workload.new("tmp/datafile", 8192, 32768) }.not_to raise_error
  end

  let(:workload) { Rperf::Workload.new("tmp/datafile", "32 KiB") }

  it "should default to 8KiB blocksize" do
    workload.blocksize.should == 8192
  end

  it "should default to write" do
    workload.type.should == :write
  end

  it "should default to sequential ordering" do
    workload.order.should == :sequential
  end

  it "should default to non-looping" do
    workload.loop.should be false
  end

  describe "device IO offsets/range" do

    it "start_offset should default to zero" do
      workload.start_offset.should == 0
    end

    it "should allow you to specify the start/end offsets" do
      expect { workload.start_offset = 512 }.not_to raise_error
      expect { workload.end_offset = 10512 }.not_to raise_error
    end

    it "should correctly calculate the IO size" do |variable|
      workload.start_offset = 512
      workload.end_offset = 10512
      workload.size.should == 10000
    end

    it "should allow you to use units for offsets" do |variable|
      workload.start_offset = "8 KiB"
      workload.start_offset.should == 8192
      workload.end_offset = "32 KiB"
      workload.end_offset.should == 32768
    end

  end

  describe "#stats" do
    it "should return an Rperf::Stats object" do
      workload.device.stats.class.should == Rperf::DeviceStats
    end
  end

  describe "#threads" do
    it "should default to a single thread" do
      workload.threads.should == 1
    end

    it "should create a worker for each thread" do
      workload.threads.times do |i|
        workload.workers[i-1].class.should == Rperf::Worker
      end
    end
  end

  it "should start with bytes_written == 0" do
    workload.device.stats.bytes_written.should == 0
  end

  it "should write one block when step is called" do
    workload.workers[0].step!
    workload.device.stats.bytes_written.should == 8192
  end

  it "should by fill a file with random data when run is called" do
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

  it "should create one worker for each thread" do
    workload.threads = 4
    workload.workers.size.should == 4
  end

  it "should fill a file with random data with multiple workers" do
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

