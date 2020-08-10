# frozen_string_literal: true

require 'unicode/blocks'
require 'unicode/sequence_name'
require 'unicode/name'
require 'byebug'

# Engine for extracting emojis from a string and looking up their names
class EmojiProcessor
  attr_reader :emojis

  NON_EMOJI_REGEX = /\p{In Basic Latin}
    |\p{In General Punctuation}
    |\p{In Combining Diacritical Marks}
    |\p{In Greek and Coptic}
    |\p{In Latin-1 Supplement}
    |\p{In Braille Patterns}
    |\p{In Latin Extended-A}/x.freeze

  def initialize
    @emojis = {}
  end

  def get_emoji(emoji)
    if @emojis[emoji]
      @emojis[emoji].ecount += 1
    else
      new_emoji = Emoji.new(emoji)
      @emojis[emoji] = new_emoji unless new_emoji.ename.nil?
    end
    # may return nil
    @emojis[emoji]
  end

  def process_emojis(emojis)
    emoji_info = []
    until emojis.empty?
      emoji_parsed = nil

      # we don't know how many characters may comprise the first emoji,
      # so we check groups of decreasing length until we get a hit
      [4, 3, 2, 1].each do |emoji_length|
        # skip unless we're still looking and there are enough characters left to check
        next unless emoji_parsed.nil? && emojis.length >= emoji_length

        # check the first x characters where x = emoji_length
        emoji_parsed = get_emoji(emojis[0..emoji_length - 1])
        # remove used chars if emoji found
        emojis = emojis[emoji_length..emojis.length] unless emoji_parsed.nil?
      end

      emoji_info << emoji_parsed
    end
    emoji_info
  end

  def process(input)
    emoji_info = process_emojis(input.gsub(NON_EMOJI_REGEX, ''))
  end
end
