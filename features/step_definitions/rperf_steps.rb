require 'digest'

Given /^A ([\d_]+) byte file named "(.*?)" in the current directory$/ do |size, filename|
  f = File.new(filename, 'w')
  f.seek(size.to_i - 1)
  f.puts ""
  f.close
end

Then /^Each ([\d_]+) byte block of "(.*?)" should be unique$/ do |blocksize, filename|
  sha1 = Digest::SHA1.new
  File.open(filename, "r") do |f|
    seen = []
    i = 0
    more_to_read = true
    while more_to_read do
      begin
	block = f.sysread(blocksize.to_i)
      rescue EOFError
	more_to_read = false
	break
      end
      i += 1
      hash = sha1.hexdigest block
      seen.should_not include(hash)
      seen << hash
    end
  end
end

