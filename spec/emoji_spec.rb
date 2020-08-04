# frozen_string_literal: true
require 'emoji'

describe Emoji do
  describe 'name' do
    context 'given 🤔' do
      it 'returns "THINKING FACE"' do
        emoji = Emoji.new('🤔')
        expect(emoji.ename).to eql('THINKING FACE')
      end
    end
  end
end
