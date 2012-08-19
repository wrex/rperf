Feature: basic command line invocation
  As a user performing IO testing
  In order to generate IO load to specific devices
  I want to be able to run rperf from the command line

  Scenario: Basic UI
    When I get help for "rperf"
    Then the exit status should be 0
    And the banner should be present
    And the banner should include the version
    And the banner should document that this app takes options
    And the following options should be documented:
      |--version|
    And the banner should document that this app's arguments are:
      |COMMANDS|which is required|


  Scenario: Simple sequential write
    Given a file named "my_test" with:
      """
      datafile = Device.new("tmp/datafile", "32 KiB")

      w1 = Workload.new("Sequential fill") do |w|
        w.device = datafile, 0, "16 KiB" # IO to first 16 KiB in device
        w.blocksize = "8 KiB"
        w.sequential_write
      end

      w1.run!
      """
    When I run `rperf my_test`
    Then each 8_192 byte block of "tmp/datafile" should be unique
    
# vim: ai sw=2 tm=75
