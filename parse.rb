#!/usr/bin/env ruby
# frozen_string_literal: true
require './lib/emoji.rb'
require './lib/emojiprocessor.rb'
require 'csv'

require 'byebug'

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
input = CSV.read('stoptmx.csv', skip_blanks: true, row_sep: "\r\r\n", headers: true)

input.each_with_index do |row, index|
  @row_number = index + 1
  str = row['GraphImages/edge_media_to_caption/edges/0/node/text']
  next if str.nil?

  id = row['GraphImages/id']
  emoji_rows = emojiprocessor.process(str)
  @html += "<h2>Row #{@row_number}: #{id}</h2\n<div class=\"str\">#{str}</div>\n<h3>Emojis#{ ' none' if emoji_rows.count == 0}</h3>\n"
  next if emoji_rows.count == 0

  @html += "<table border=\"1\">\n"
  @html += "<tr><th>Emoji</th><th>Length</th><th>Unicode</th><th>Name</th><th>Blocks</th><th>Count</th></tr>\n"
  emoji_rows.each do |emoji_info|
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
File.open("stoptmx.html", "w:UTF-8") do |f| 
  f.write @html
end 

puts 'done'