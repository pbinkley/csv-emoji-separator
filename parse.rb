#!/usr/bin/env ruby

require 'unicode/blocks'
require 'unicode/sequence_name'
require 'unicode/name'
require 'csv'

require 'byebug'

NON_EMOJI_REGEX = /\p{In Basic Latin}
  |\p{In General Punctuation}
  |\p{In Combining Diacritical Marks}
  |\p{In Greek and Coptic}
  |\p{In Latin-1 Supplement}
  |\p{In Braille Patterns}
  |\p{In Latin Extended-A}/x.freeze

@emojis = {}

@html = "<html><head><meta charset=\"UTF-8\"><title>Emojis</title></head><body><h1>Emojis</h1>\n"
@html += "<p>Generated at: #{Time.now}</p>\n"
@html += "<p><a href=\"#list\">Jump to Emoji List</a></p>\n"

def get_name(emoji)
  if @emojis[emoji]
    @emojis[emoji][:count] += 1
    @emojis[emoji]
  else
    name = emoji.length == 1 ? Unicode::Name.of(emoji) : Unicode::SequenceName.of(emoji)
    if name.nil?
      nil
    else
      @emojis[emoji] = { name: name,
                         length: emoji.length,
                         block: Unicode::Blocks.blocks(emoji),
                         count: 1 }
      @emojis[emoji]
    end
  end
end

def process_emojis(emojis)
  names = []
  until emojis.empty?
    name = nil
    emoji = nil
    emoji_hash = nil
    [3, 2, 1].each do |emoji_length|
      next unless emoji_hash.nil? && emojis.length >= emoji_length

      emoji = emojis[0..emoji_length - 1]
      emoji_hash = get_name(emoji)
      # remove used chars
      emojis = emojis[emoji_length..emojis.length] unless emoji_hash.nil?
    end
    @html += "<tr><td>#{emoji}</td><td>#{emoji_hash[:length]}</td><td>#{emoji.chars.map { |c| c.ord.to_s(16) }}</td><td>\"#{emoji_hash[:name]}\"</td><td>#{emoji_hash[:block]}</td></tr>\n"
    puts "#{emoji}: \"#{emoji_hash[:name]}\" | #{emoji_hash[:block]} | #{emoji_hash[:count]}"
    names << emoji_hash[:name]
  end
  names
end

# note: stopmtx.csv has weird line separators: 0d 0d 0a
input = CSV.read('stoptmx.csv', skip_blanks: true, row_sep: "\r\r\n", headers: true)

input.each_with_index do |row, index|
  @row_number = index + 1
  str = row['GraphImages/edge_media_to_caption/edges/0/node/text']
  id = row['GraphImages/id']
  @html += "<h2>Row #{@row_number}: #{id}</h2\n<div class=\"str\">#{str}</div>\n<h3>Emojis</h3>\n<table border=\"1\">\n"
  @html += "<tr><th>Emoji</th><th>Length</th><th>Unicode</th><th>Name</th><th>Blocks</th></tr>\n"
  next if str.nil?

  emojis = str.gsub(NON_EMOJI_REGEX, '')
  names = process_emojis(emojis)
  @html += "</table><hr>\n"

end

@html += "<h2 id=\"list\">Emoji List</h2>\n"
@html += "<table border=\"1\"><tr><th>Emoji</th><th>Length</th><th>Unicode</th><th>Name</th><th>Blocks</th><th>Count</th></tr>\n"
@emojis.keys.sort.each do |emoji|
  emoji_hash = @emojis[emoji]
  @html += "<tr><td>#{emoji}</td><td>#{emoji_hash[:length]}</td><td>#{emoji.chars.map { |c| c.ord.to_s(16) }}</td><td>\"#{emoji_hash[:name]}\"</td><td>#{emoji_hash[:block]}</td><td>#{emoji_hash[:count]}</td></tr>\n"
end

@html += "</table></body></html>"
File.open("stoptmx.html", "w:UTF-8") do |f| 
  f.write @html
end 



puts 'done'