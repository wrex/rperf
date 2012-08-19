require 'rperf'

describe Rperf::Device do
  it "should require a pathname" do
    expect { Rperf::Device.new }.to raise_error ArgumentError
  end

  it "should open a file" do
    Rperf::Device.new("tmp/datafile").file.class.should == File
  end
end
