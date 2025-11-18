class Validator
  # In a production setting a nice pattern for this might be a validator class which
  # can be instantiated with a proc that checks for a desired characteristic.
  # In this sense each instantiated validator would represent a rule to be checked.
  # The instantiated validators can then be stacked in a queue and run through according
  # to some criteria. I believe Rails validators work in a similar way to what I am describing.
  
  # Such validators could be customized or written into a database, which is a handy pattern for
  # white-label saas products.

  # The validator class I have written here is obviously a very simple implementation
  # where one class handles everything and there is no metaprogramming.

  VALID_LOCATIONS = {
    origins: ['Munich Hbf'],
    destinations: ['Berlin Hbf (tief)', 'Stockholm Central Bus Station']
  }

  VALID_DATES = {
    'Berlin Hbf (tief)': DateTime.new(2025, 11, 14, 16, 46, 0, '+01:00'),
    'Stockholm Central Bus Station': DateTime.new(2025, 11, 12, 03, 45, 0, '+01:00')
  }

  # If desired it would be possible to use accessors to avoid passing values around
  # double splat is not really necessary here because the arg list is so short and we know what they should be
  # but generally it is a nice thing to use for validator-like classes
  def self.validate!(**args)
    validate_origin(args[:from])
    validate_destination(args[:to])
    validate_date(args[:to], args[:departure_at])
  end

  private

  # validate_origin and validate_destination are so similar that they could obviously be combined in a refactoring
  def self.validate_origin(from)
    return if VALID_LOCATIONS[:origins].include? from

    raise ArgumentError, "Your origin must be 'Munich Hbf'"
  end

  def self.validate_destination(to)
    return if VALID_LOCATIONS[:destinations].include? to

    raise ArgumentError, "Your destination must be 'Berlin Hbf (tief)' or 'Stockholm Central Bus Station'"
  end

  def self.validate_date(to, departure_at)
    # If VALID_DATES was a rocket hash we wouldn't need to_sym
    return if VALID_DATES[to.to_sym] == departure_at

    raise ArgumentError, 'You have entered an incorrect departure time for your desired destination'
  end
end
