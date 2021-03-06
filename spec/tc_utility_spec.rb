require 'rperf'

describe Rperf do
  describe "::normalize_units" do

    it "should leave valid numbers alone (numeric or string)" do
      Rperf::normalize_units(4321).should == 4321
      Rperf::normalize_units('4321').should == 4321
    end

    it "should turn '8 KiB' into 8192" do
      Rperf::normalize_units("8 KiB").should == 8192
    end

    it "should ignore white space" do
      Rperf::normalize_units("8KiB").should == 8192
      Rperf::normalize_units("8\tKiB").should == 8192
      Rperf::normalize_units("8 \t KiB").should == 8192
      Rperf::normalize_units("8KiB    \n").should == 8192
      Rperf::normalize_units("\t   8KiB").should == 8192
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
      Rperf::normalize_units("3 TiB").should == 1_099_511_627_776 * 3
    end

    it "should leave invalid strings alone" do
      Rperf::normalize_units("foobizzle").should == "foobizzle"
    end

    it "should leave NaN alone" do
      Rperf::normalize_units(Float::NAN).should be_nan
      Rperf::normalize_units(0.0/0.0).should be_nan
    end
  end
end

