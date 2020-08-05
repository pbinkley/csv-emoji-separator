## Installation

- [Install Ruby ](https://www.ruby-lang.org/en/documentation/installation/) (if not already installed)
- [Install Bundler](https://bundler.io/): ```gem install bundler```
- Download the code from this repository or (better) clone it with git
- Open a terminal, cd to the code directory, and type ```bundle install``` to install the dependencies

## Running

- in a terminal type ```./parse.rb``` to run the script
- It accepts three parameters, in this order:
  - the name of the input file
  - the name of the column containing text to be parsed for emojis
  - the name of the column containing the id of the row
- The default values are set [here](https://github.com/pbinkley/csv-emoji-separator/blob/ee4817d533a8250d155db63348f2c5beddefbd91/parse.rb#L9-L11), and are suitable for the test csv
- The script will output two files: ```<inputfile>-output.html``` and ```<inputfile>-output.csv```.

## Tests

There are RSpec tests for the basic functionality. Run ```bundle exec rspec```.
