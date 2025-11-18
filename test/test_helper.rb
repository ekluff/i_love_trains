require 'minitest/autorun'
require 'date'
require 'json'

# load up all the ruby files in the lib dir of our application
Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each do |file|
  require file
end