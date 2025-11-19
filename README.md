# Quickstart

To use this project, clone it onto your machine, navigate to the project dir, and run:

```bin/i_love_trains```

This script will provide further instructions and launch an interactive ruby environment.

# Depedencies

This project was intentionally written with minimal dependencies. You need a working installation of ruby and irb.

To experiment with the code in ferrum_playground.rb, you will also need to install the Ferrum gem.

### Test suite

The tests are written in minitest instead of rspec, because minitest is included with the standard ruby distribution.

To run the tests:

```ruby
ruby test/scraper/thetrainline_test.rb
```

# Further development possibilities

This tool could easily be turned into a gem that manages its own dependencies and has a small CLI for usability. It could also be containerized for more advanced dependency management.

The test suite should be expanded if this were a production application.

# General notes

I tried to use a variety of code styles to demonstrate my familiarity with various concepts. The code contains extensive comments so that the evaluators may gain insights into my thought processes.

## AI Usage

There is very little AI written code in this project. AI did help me troubleshoot a few things like hard-to-find syntax errors.

AI was helpful in quickly setting up Minitest, because I am more familiar with Rspec. In the end, however, it was suggesting tests that were extremely complex with many depedencies, so I just wrote a few simple ones myself.

## Project Structure

The project is divided into several directories: bin, data, lib, and test.

**bin** contains an executable ruby script which requires dependencies, autoloads all of the ruby files in the lib dir, prints instructions for the user, and runs IRB.

**data** contains response body json objects from the /api/journey-search endpoint. One of these two files is then selected depending on the user's input.

**lib** contains the project business logic. 
  - lib/scraper/thetrainline is the app's entry point. It calls the validator and the parser, and determines which response object file to load.
  - lib/parser contains the app's main business logic. It accepts the response object body, parses it, and iterates through journeys to build the output array. It contains a public class method _parse_, which instantiates the class and calls an instance method of the same name. The public instance method _parse_ then calls the private instance method _build_response_. This method contains the core logic of the application.
  - lib/validator runs a few simple validations on the user input. It contains a public class method _validate!_. This calls methods that read and apply valid patterns defined by contants in Validator, and raises ArgumentError for invalid arguments.

**test** contains a (admittedly very basic) minitest suite. See comments in these files for more details.

In the root dir, there are two more files: ferrum_playground.rb and schema_notes.md

**ferrum_playground.rb** contains code for the web scraping gem Ferrum. In this file I experimented with ways to scrape the trainline website. The code in this file **does not fully work** and is not finished. See the comments in this file for why I commited the code anyways, and what I was trying to accomplish with it.

**schema_notes.md** contains my notes of the project's input and output specs, the schema of the response object, and an example of the request body. Its contents is somewhat unrefined as it was intened not as documentation but as a tool to help me develop the app.