# frozen_string_literal: true

require 'unicode/blocks'
require 'unicode/sequence_name'
require 'unicode/name'

# Holds information about a single emoji
class Emoji
  attr_reader :ename, :elength, :eblock, :ecount, :emoji
  attr_writer :ecount

  def initialize(emoji)
    @emoji = emoji
    name = @emoji.length == 1 ? Unicode::Name.of(@emoji) : Unicode::SequenceName.of(@emoji)
    return if name.nil?

    @ename = name
    @elength = @emoji.length
    @eblock = Unicode::Blocks.blocks(@emoji)
    @ecount = 1
  end

  def to_hash
    { emoji: @emoji,
      ename: @ename,
      elength: @elength,
      eblock: @eblock,
      ecount: @ecount }
  end

  def to_html
    "<tr>
      <td>#{@emoji}</td>
      <td>#{@elength}</td>
      <td>#{@emoji.chars.map { |c| c.ord.to_s(16) }}</td>
      <td>\"#{@ename}\"</td>
      <td>#{@eblock}</td>
      <td>#{@ecount}</td>
    </tr>\n"
  end
end
