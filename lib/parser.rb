class Parser
  # TODO obviously this only works on my machine but I'm developing this class in irb
  # change to relative path or better yet, move logic
  FILE_PATH = '/Users/evanclough/code/i_love_trains/data/munich-berlin.json'
  
  # I originally tried to see if ChatGPT could help write this class. TLDR: absolutely not
  # Some of the bugs were extremely funny, as tends to the be the case with AI
  # Every few months I like to check if the tools can do what they promise, answer continues to be not really
  # In the end it wasn't even worth trying to debug, so I just wrote this completely from scratch (except the regex)

  attr_reader :json_data, :journey_search, :journeys, :alternatives, :fares, :legs, :sections, :locations, :carriers, :transport_modes, :fare_types

  # TODO remove nil default
  def initialize(response_obj=nil)
    # TODO in final implementation, read response obj instead of file
    # fallback to file if response_obj is nil
    # this works either way but behavior is unexpected so still want to clean it up
    response_obj ||= File.read(FILE_PATH)

    @json_data = JSON.parse(response_obj)['data']    
    @journey_search = json_data['journeySearch']
    @journeys = journey_search['journeys']      
    @alternatives = journey_search['alternatives']
    @fares = journey_search['fares']
    @legs = journey_search['legs']
    @sections = journey_search['sections']    
    @locations = json_data['locations']
    @carriers = json_data['carriers']
    @transport_modes = json_data['transportModes']
    @fare_types = json_data['fareTypes']  
  end

  # TODO remove nil default
  def self.parse(response_obj=nil)
    Parser.new(response_obj).parse
  end

  def parse
    out = []

    journeys.each do |journey_id, journey|
      # if there are no sections the journey is unsellable and we can't easily get the data we want
      # in a more thorough implementation we would get our data from the legs, as mentioned below
      # but you can't buy it anyways so you don't get to see it!
      next if journey['sections'].empty?

      # fares are for the whole journey, so we only need to check one of them for origin/dest
      # it would be simpler to get this from the legs, but I'm not confident the legs are always listed chronologically and I don't want to check
      # If we were to iterate fares anyways, an alternative would be to populate the value if nil, but I already wrote this and it works
      # journey > section > alternative > fare > location:name
      first_fare = fares[alternatives[sections[journey['sections'].first]['alternatives'].first]['fares'].first]
      journey_legs = legs.select {|k| journey['legs'].include? k}

      out << {
        # journey > section > alternative > fare:origin > location:name
        departure_station: locations[first_fare['origin']]['name'],
        departure_at: DateTime.parse(journey['departAt']),
        # journey > section > alternative > fare:destination > location:name
        arrival_station: locations[first_fare['destination']]['name'],
        arrival_at: DateTime.parse(journey['arriveAt']),
        # because we don't care about the order we can this get directly from journey > legs > carriers:name
        # normally might be nice to break this up so it's more readable; I generally don't like code like this because it's easy to write and harder to debug
        service_agencies: carriers.select {|k| journey_legs.map {|k,v| v['carrier']}.include? k}.map {|k,v| v['name'] },
        duration_in_minutes: convert_duration(journey['duration']),
        # fun pitfall here: beware the fencepost problem! https://en.wikipedia.org/wiki/Off-by-one_error
        changeovers: journey['legs'].count - 1,
        # journey > legs > transport mode:mode
        products: transport_modes.select {|k| journey_legs.map {|k,v| v['transportMode']}.include? k}.map {|k,v| v['mode'] },
        # journey > section > alternative > fare
        fares: journey_fare_details(journey)
      }
    end
    
    out
  end

  private

  def journey_fare_details(journey)
    # I don't love this big pile of parser logic here because the variables are only used once, right here (so, why bother assigning?)
    # and the only purpose is to drill down from journey to alternative (and subsequently to fare)
    # in production code I might try to think of a neater way to handle this
    journey_sections = sections.select {|k| journey['sections'].include? k}
    journey_alternative_ids = journey_sections.reduce([]) {|alternative_ids, section| alternative_ids += section[1]['alternatives'] }
    journey_alternatives = alternatives.select {|k| journey_alternative_ids.include? k}

    journey_alternatives.map do |id, alternative|
      # Alternatives have one Fare per passenger, i.e., two passengers two fares
      # Since our tool doesn't accept passenger numbers we will assume there will always only be one Passenger/Fare
      # This significantly simplifies the logic because we don't have to match anything up or iterate again
      alternative_fare = fares[alternative['fares'].first]
      alternative_fare_type = fare_types[alternative_fare['fareType']]

      {
        name: alternative_fare_type['name'],
        # I guess it's possible a user could be using Thai Bhat or something and a static conversion like this would fail
        # In that case we would have to look up a conversion using the currency but that feels out of scope for this exercise
        # convert to int because the spec does not show a decimal
        price_in_cents: (alternative['price']['amount']*100).to_i,
        currency: alternative['price']['currencyCode'],
        travel_classes: alternative_fare['fareLegs'].map {|fare_leg| fare_leg['travelClass']['name']},
        conditions: alternative_fare_type['conditionsSummary']
      }
    end
  end

  def convert_duration(iso8601_str)
    # claude wrote this regex, but I directed it to do so using capture groups containing
    # capturing characters for the digits and noncapturing for the descriptor letters
    # I could have written it myself but it would have taken longer
    # naming the capture groups isn't really necessary but makes it easier to understand
    # if a train trip takes over a year, this will break :-)
    regex = /P(?:(?<days>\d+)D)?T?(?:(?<hours>\d+)H)?(?:(?<minutes>\d+)M)?/
    match = iso8601_str.match(regex)
    sum = 0
    # calling to_i also takes care of nil conversion
    sum += match[:days].to_i*24*60
    sum += match[:hours].to_i*60
    sum += match[:minutes].to_i
  end
end
