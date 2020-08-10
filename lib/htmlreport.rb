# frozen_string_literal: true

require './lib/emoji.rb'

# HTML report generated from input csv
class HTMLReport
  def initialize
    @html = "<html><head><meta charset=\"UTF-8\"><title>Emojis</title></head><body><h1>Emojis</h1>\n"
    @html += "<p>Generated at: #{Time.now}</p>\n"
    @html += "<p><a href=\"#list\">Jump to Emoji List</a></p>\n"
  end

  def add_row(row_number, id, str, count)
    @html += "<h2>Row #{row_number}: #{id}</h2\n"
    @html += "<div class=\"str\">#{str}</div>\n"
    @html += "<h3>Emojis#{' none' if count.zero?}</h3>\n"
  end

  def add_emojis(emoji_array)
    @html += "<table border=\"1\">\n"
    @html += "<tr><th>Emoji</th><th>Length</th><th>Unicode</th><th>Name</th><th>Blocks</th><th>Count</th></tr>\n"
    emoji_array.each do |emoji_info|
      @html += emoji_info.to_html
    end

    @html += "</table><hr>\n"
  end

  def finish(emojis, outputhtml)
    @html += "<h2 id='list'>Emoji List</h2>\n"
    @html += "<table border='1'><tr><th>Emoji</th><th>Length</th><th>Unicode</th>"
    @html += "<th>Name</th><th>Blocks</th><th>Count</th></tr>\n"
    emojis.keys.sort.each do |emoji|
      emoji_hash = emojis[emoji]
      @html += emoji_hash.to_html
    end

    @html += '</table></body></html>'

    # write html file
    File.open(outputhtml, 'w:UTF-8') do |f|
      f.write @html
    end
  end
end
