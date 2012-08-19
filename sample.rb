# Sample command file for rperf command
#

# TODO: need to allow multiple workloads to the same device!
datafile_wl = Workload.new("/tmp/datafile") do |w|
  w.start_offset = 0
  w.end_offset = "16 KiB"
  w.blocksize = "8 KiB"
  w.type = :write
  w.order = :sequential
  w.threads = 1
  w.add_reporter(:standard, 2) # text line every two seconds to stdout
end

sdb_wl = Workload.new("/dev/sdb") do |w|
  w.start_offset = 8192
  w.end_offset = "50 GiB"
  w.blocksize = "8 KiB"
  w.io_type = :read_write
  w.order = :random
  w.read_percent = 70
  w.threads = 16
  w.dedupe = 50
  w.compression = 50
  w.add_reporter(:html, 2) # text line every two seconds to stdout
end

datafile_wl.run! and puts "Completed sequential fill of #{w.device.pathname}"
sdb_wl.run_timed("90 minutes") and puts "Completed 90 minute IO test of /dev/sdb"
