require_relative 'deck'


class Hand
    
    def initialize
        @cards = []
    end

    def empty?
        @cards.length == 0
    end

    def full?
        @cards.length == 5 
    end

    def add_card(card)
        raise 'Argument is not a card' unless card.is_a?(Card)
        raise 'Hand is full' if full?
        @cards << card
        card
    end

    def discard(num)
        raise 'Argument does not indicate a card on hand' unless num.is_a?(Integer)
        raise 'No cards in hand' if empty?

        @cards.delete_at(num - 1)
    end

    def to_s
        return [] if empty?
        @cards.map{|card| card.to_s}
    end

    def to_n
        return [] if empty?
        @cards.map{|card| card.to_n}
    end

    def straight?
        hand = to_n
        if hand.include?(14) && !hand.include?(13)
            hand.delete(14)
            hand << 1
        end
        hand.sort_by!{|value| value}
        hand.last - hand.first == 4
    end

    def flush?
        @cards.map{|card| card.suit}.uniq.length == 1 
    end

    def royal_flush?
        hand = to_n
        straight? && flush? && hand.include?(13) && hand.include?(14)
    end
end