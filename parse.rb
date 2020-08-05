#!/usr/bin/env ruby
# frozen_string_literal: true
require './lib/emoji.rb'
require './lib/emojiprocessor.rb'
require 'csv'

require 'byebug'

inputfile = ARGV[0] || 'stoptmx.csv'
inputcolumn = ARGV[1] || 'GraphImages/edge_media_to_caption/edges/0/node/text'
idcolumn = ARGV[2] || 'GraphImages/id'

outputhtml = "#{inputfile.sub(/.csv$/, '')}-output.html"
outputcsv  = "#{inputfile.sub(/.csv$/, '')}-output.csv"

NON_EMOJI_REGEX = /\p{In Basic Latin}
  |\p{In General Punctuation}
  |\p{In Combining Diacritical Marks}
  |\p{In Greek and Coptic}
  |\p{In Latin-1 Supplement}
  |\p{In Braille Patterns}
  |\p{In Latin Extended-A}/x.freeze

@html = "<html><head><meta charset=\"UTF-8\"><title>Emojis</title></head><body><h1>Emojis</h1>\n"
@html += "<p>Generated at: #{Time.now}</p>\n"
@html += "<p><a href=\"#list\">Jump to Emoji List</a></p>\n"

emojiprocessor = EmojiProcessor.new

# note: stopmtx.csv has weird line separators: 0d 0d 0a
data = CSV.read(inputfile, skip_blanks: true, row_sep: "\r\r\n", headers: true)

data.each_with_index do |row, index|
  @row_number = index + 1
  # add new columns
  row['emojis'] = nil
  row['emoji_names'] = nil

  str = row[inputcolumn]
  next if str.nil?

  id = row[idcolumn]
  emoji_array = emojiprocessor.process(str)

  @html += "<h2>Row #{@row_number}: #{id}</h2\n<div class=\"str\">#{str}</div>\n<h3>Emojis#{ ' none' if emoji_array.count == 0}</h3>\n"
  next if emoji_array.count == 0

  # insert columns for emojis and emoji-names
  row['emojis'] = emoji_array.map { |e| e.emoji }.join('|')
  row['emoji_names'] = emoji_array.map { |e| e.ename }.join('|')

  @html += "<table border=\"1\">\n"
  @html += "<tr><th>Emoji</th><th>Length</th><th>Unicode</th><th>Name</th><th>Blocks</th><th>Count</th></tr>\n"
  emoji_array.each do |emoji_info|
    @html += emoji_info.to_html
  end

  @html += "</table><hr>\n"
end

@emojis = emojiprocessor.emojis

@html += "<h2 id=\"list\">Emoji List</h2>\n"
@html += "<table border=\"1\"><tr><th>Emoji</th><th>Length</th><th>Unicode</th><th>Name</th><th>Blocks</th><th>Count</th></tr>\n"
@emojis.keys.sort.each do |emoji|
  emoji_hash = @emojis[emoji]
  @html += emoji_hash.to_html
end

@html += "</table></body></html>"

# write html file
File.open(outputhtml, "w:UTF-8") do |f| 
  f.write @html
end 

# write csv file
File.open(outputcsv, 'w:UTF-8') do |f|
  f.write(data.to_csv)
end

puts 'done'