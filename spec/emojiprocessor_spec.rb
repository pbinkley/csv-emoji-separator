# frozen_string_literal: true

require 'emojiprocessor'
require 'byebug'

describe EmojiProcessor do
  describe 'get_name' do
    context 'given 🤔' do
      it 'returns "THINKING FACE"' do
        emojiprocessor = EmojiProcessor.new
        expect(emojiprocessor.get_emoji('🤔').ename).to eql('THINKING FACE')
      end
      it 'counts "THINKING FACE"' do
        emojiprocessor = EmojiProcessor.new
        throwaway = emojiprocessor.get_emoji('🤔')
        expect(emojiprocessor.get_emoji('🤔').ecount).to eql(2)
      end
    end
    describe 'process_emojis' do
      context 'given 🌺✌️🌍'
      emojiprocessor = EmojiProcessor.new
      output = emojiprocessor.process_emojis('🌺✌️🌍')
      it 'gets three emojis' do
        expect(output.count).to eql(3)
      end
      it 'expects first emoji to be HIBISCUS' do
        expect(output[0].ename).to eql('HIBISCUS')
      end
    end
  end
end
