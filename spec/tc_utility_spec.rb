require 'rperf'

describe Rperf do
  describe "#normalize_units" do
    it "should turn '8 KiB' into 8192" do
      Rperf::normalize_units("8 KiB").should == 8192
    end

    it "should ignore spaces" do
      Rperf::normalize_units("8KiB").should == 8192
      Rperf::normalize_units("8\tKiB").should == 8192
      Rperf::normalize_units("8 \t KiB").should == 8192
    end

    it "should leave numbers without units alone ('1234' -> 1234)" do
      Rperf::normalize_units("1234").should == 1234
    end

    it "should ignore case" do
      Rperf::normalize_units("8 kiB").should == 8192
    end

    it "should turn '8 KB' into 8000" do
      Rperf::normalize_units("8 KB").should == 8000
    end

    it "should turn '1 MB' into 1_000_000" do
      Rperf::normalize_units("1 MB").should == 1_000_000
    end

    it "should turn '1 GB' into 1_000_000_000" do
      Rperf::normalize_units("1 GB").should == 1_000_000_000
    end

    it "should turn '1 TB' into 1_000_000_000_000" do
      Rperf::normalize_units("1 TB").should == 1_000_000_000_000
    end

    it "should turn '1 MiB' into 1_048_576" do
      Rperf::normalize_units("1 MiB").should == 1_048_576
    end

    it "should turn '1 GiB' into 1_073_741_824" do
      Rperf::normalize_units("1 GiB").should == 1_073_741_824
    end

    it "should turn '1 TiB' into 1_099_511_627_776" do
      Rperf::normalize_units("1 TiB").should == 1_099_511_627_776
    end

    it "should convert invalid strings to 0" do
      Rperf::normalize_units("foobizzle").should == 0
    end

  end
end

