require_relative 'card'

class Deck
    attr_reader :queue

    def initialize
        combinations = Card.values.product(Card.suits)
        @queue = combinations.map {|value,suit| Card.new(value,suit)}
    end

    def empty?
        @queue.empty?
    end

    def draw_card
        @queue.pop
    end

    def add_card(card)
        raise 'Deck is full' if full?
        raise 'Invalid argument for card' unless card.is_a?(Card)
        raise "Can not add duplicate card" if @queue.include?(card)
        @queue.unshift(card)
        card
    end

    def full?
        @queue.length == 52
    end

    def shuffle!
        @queue.shuffle!
    end
end