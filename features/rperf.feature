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
      |FILE_OR_DEVICE|which is required|


  Scenario: Default load generation # One stream of sequential writes
    Given A 1_000_000 byte file named "myfile" in the current directory
    When I run `rperf myfile`
    Then I should exactly fill "myfile" with random data
    

# vim: ai sw=2 tm=75
