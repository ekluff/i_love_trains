require_relative '../test_helper'

# These are more integration tests than unit tests. The behavior of the individual file is not isolated,
# and we allow the tests to call the file system and various other classes without stubbing or mocking.

# On a more complex app it would be desireable to isolate the behavior of individual methods and limit
# interaction with external resources for performance and reliability reasons, as well as the ease of 
# troubleshooting of individual classes and depedency management.

# However, for our simple app, pretty much all behavior can reasonably be tested from our one entrypoint
# and I just want a few simple fire tests.

# There are some possible optimizations here; for example, we could do something similar to rspec contexts
# and run the query once, then perform multiple tests against it

module Scraper
  class ThetrainlineTest < Minitest::Test
    def setup
      @right_args = {from: 'Munich Hbf', to: 'Berlin Hbf (tief)', departure_at: DateTime.new(2025, 11, 14, 16, 46, 0, '+01:00')}
      @wrong_args = {from: 'Turin', to: 'Stockholm Central Bus Station', departure_at: DateTime.new(2025, 11, 14, 16, 46, 0, '+01:00')}
    end

    def test_find_with_wrong_args_raises_argumenterror
      assert_raises(ArgumentError) do
        Scraper::Thetrainline.find(**@wrong_args)
      end
    end

    def test_find_with_nil_args_raises_argumenterror
      assert_raises(ArgumentError) do
        Scraper::Thetrainline.find()
      end
    end

    def test_find_with_right_args_returns_array_length_5
      result = Thetrainline.find(**@right_args)

      assert_kind_of Array, result
      assert_equal 5, result.length # only true for destination Berlin
    end

    def test_find_with_right_args_array_has_correct_keys
      result = Thetrainline.find(**@right_args)
      correct_keys = [
        :departure_station,
        :departure_at,
        :arrival_station,
        :arrival_at,
        :service_agencies,
        :duration_in_minutes,
        :changeovers,
        :products,
        :fares
      ].sort

      result.first.keys.sort == correct_keys
    end
  end
end
