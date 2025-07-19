ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Include test data helper
    include TestDataHelper

    # Add more helper methods to be used by all tests here...
    
    # Helper method to travel in time for testing
    def travel_to_time(time)
      travel_to(time) do
        yield
      end
    end
  end
end
