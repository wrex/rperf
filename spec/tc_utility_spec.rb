require 'rperf'

describe Rperf do
  describe "#de_unitize" do
    it "should turn '8 KiB' into 8192" do
      Rperf::de_unitize("8 KiB").should == 8192
    end

    it "should ignore spaces" do
      Rperf::de_unitize("8KiB").should == 8192
      Rperf::de_unitize("8\tKiB").should == 8192
      Rperf::de_unitize("8 \t KiB").should == 8192
    end

    it "should leave numbers without units alone ('1234' -> 1234)" do
      Rperf::de_unitize("1234").should == 1234
    end

    it "should ignore case" do
      Rperf::de_unitize("8 kiB").should == 8192
    end

    it "should turn '8 KB' into 8000" do
      Rperf::de_unitize("8 KB").should == 8000
    end

    it "should turn '1 MB' into 1_000_000" do
      Rperf::de_unitize("1 MB").should == 1_000_000
    end

    it "should turn '1 GB' into 1_000_000_000" do
      Rperf::de_unitize("1 GB").should == 1_000_000_000
    end

    it "should turn '1 TB' into 1_000_000_000_000" do
      Rperf::de_unitize("1 TB").should == 1_000_000_000_000
    end

    it "should turn '1 MiB' into 1_048_576" do
      Rperf::de_unitize("1 MiB").should == 1_048_576
    end

    it "should turn '1 GiB' into 1_073_741_824" do
      Rperf::de_unitize("1 GiB").should == 1_073_741_824
    end

    it "should turn '1 TiB' into 1_099_511_627_776" do
      Rperf::de_unitize("1 TiB").should == 1_099_511_627_776
    end

    it "should convert invalid strings to 0" do
      Rperf::de_unitize("foobizzle").should == 0
    end

  end
end

