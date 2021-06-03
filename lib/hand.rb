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
    end

    def discard(num)
        raise 'Argument does not indicate a card on hand' unless num.is_a?(Integer)
        raise 'No cards in hand' if empty?

        @cards.delete_at(num - 1)
    end


    
end