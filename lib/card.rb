require 'colorize'

class Card
    attr_reader :value,:suit

    VALUES = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'].freeze
    SUITS = {:pike => '♠',:heart => '♥',:sword => '♣',:tile => '♦'}.freeze
    COLORS = {'♠' => :light_black,'♥' => :light_red,'♣' => :light_black,'♦' => :light_red}.freeze

    def self.values
        VALUES
    end

    def self.suits
        SUITS.keys
    end

    def initialize(value,suit)
        raise 'Argument value must be a string' unless value.is_a?(String)
        raise 'Argument suit must be a symbol' unless suit.is_a?(Symbol)
        raise 'Invalid character for argument value' unless VALUES.include?(value)
        raise 'Invalid symbol for argument suit' unless SUITS.has_key?(suit)

        @value = value
        @suit = SUITS[suit]
    end

    def to_s
        (@value + @suit).colorize(:color => COLORS[@suit],:background => :white)
    end
end