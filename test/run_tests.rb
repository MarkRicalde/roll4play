#!/usr/bin/env ruby

# Simple test runner for the Rails project
# Usage: ruby test/run_tests.rb [test_file]

require_relative 'test_helper'

# Get the test file from command line argument
test_file = ARGV[0]

if test_file
  # Run specific test file
  puts "Running tests from: #{test_file}"
  load test_file
else
  # Run all model tests
  puts "Running all model tests..."
  
  test_files = [
    'test/models/campaign_test.rb',
    'test/models/player_test.rb', 
    'test/models/session_test.rb',
    'test/models/membership_test.rb',
    'test/models/integration_test.rb'
  ]
  
  test_files.each do |file|
    puts "\nRunning #{file}..."
    load file
  end
  
  puts "\nAll tests completed!"
end 