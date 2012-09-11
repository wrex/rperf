require 'rperf'
require 'fileutils'

describe Rperf::Device do
  TMPFILE = "tmp/datafile"
  after(:all) { FileUtils.rm TMPFILE }

  it "should require a pathname" do
    expect { Rperf::Device.new }.to raise_error ArgumentError
  end

  it "should open a file" do
    FileUtils.touch TMPFILE
    Rperf::Device.new(TMPFILE).file.class.should == File
  end
end
