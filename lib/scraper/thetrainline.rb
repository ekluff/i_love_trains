module Scraper
  class Thetrainline
    # If the logic in this class was more complex, I would use a design similar to that in Parser
    # where the class method #find is simply a manager method that instantiates the class and calls
    # instance methods which encapsulate the business logic. However, in this case, the class is so
    # simple that doing so just adds complexity. Hence the use of class methods with no initializer.

    # use named args without defaults to protect from nil
    # it would also be possible to use double splat here and explicitly verify the presence and type
    # of the arguments in the validator
    # using double splat would also make the Validator.validate! call a bit cleaner
    def self.find(from:, to:, departure_at:)
      # in a more thorough implementation we might set up callbacks to run this 'automatically'
      Validator.validate!(from:, to:, departure_at:)

      Parser.parse(response_obj(to))
    end

    private

    def self.response_obj(to)
      # grab the response body corresponding to the user's destination
      # We can make some assumptions about what the inputs will be, since we validated them
      filename = "munich-#{to.split.first.downcase}.json"
      path = File.expand_path('../../../data', __FILE__)

      File.read File.join(path, filename)
    end
  end
end
