#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require './lib/emoji.rb'
require './lib/emojiprocessor.rb'
require './lib/htmlreport.rb'

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

@html_report = HTMLReport.new
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

  emoji_array = emojiprocessor.process(str)

  @html_report.add_row(@row_number, row[idcolumn], str, emoji_array.count)
  next if emoji_array.count.zero?

  # insert columns for emojis and emoji-names
  row['emojis'] = emoji_array.map(&:emoji).join('|')
  row['emoji_names'] = emoji_array.map(&:ename).join('|')

  @html_report.add_emojis(emoji_array)
end

@emojis = emojiprocessor.emojis

@html_report.finish(@emojis, outputhtml)

# write csv file
File.open(outputcsv, 'w:UTF-8') do |f|
  f.write(data.to_csv)
end

puts 'done'
