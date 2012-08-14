require 'rperf'

describe Rperf::Device do
  it "should require a pathname" do
    expect { Rperf::Device.new }.to raise_error ArgumentError
  end
end
