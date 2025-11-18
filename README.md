# Quickstart

To use this project, clone it onto your machine, navigate to the project dir, and run:

```bin/i_love_trains```

This script will provide further instructions and launch an interactive ruby environment.

# Depedencies

This project was intentionally written with minimal dependencies. You need a working installation of ruby and irb.

To experiment with the code in ferrum_playground.rb, you will also need to install the Ferrum gem.

### Test suite

The tests are written in minitest instead of rspec, because minitest is include with the standard ruby distribution.

To run the tests:

```ruby
require 'minitest'

ruby test/thetrainline_test.rb
```

# Further development possibilities

This tool could easily be turned into a gem that manages its own dependencies and has a small CLI for usability. It could also be containerized for more advanced dependency management.

# General notes

I tried to use a variety of architectural patterns in this application to demonstrate my familiarity with various concepts. The code contains extensive comments -- more than I might normally write -- so that the evaluators may gain insights into my thought processes.

## AI Usage

There is very little AI written code in this project. AI did help me troubleshoot a few things like hard-to-find syntax errors.

AI was helpful in quickly setting up Minitest, because I am more familiar with Rspec. In the end, however, it was suggesting tests that were extremely complex with many depedencies, so I just wrote a few simple ones myself.

## Regarding specific files

### ferrum_playground.rb
The code in the file ferrum_playground.rb **does not fully work**. See the comments in this file for why I commited the code anyways, and what I was trying to accomplish with it.

### schema_notes.md
schema_notes.md is my documentation of the project's input and output specs, the schema of the response object, and an example of the request body.