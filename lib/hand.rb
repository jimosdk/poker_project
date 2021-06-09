require_relative 'deck'
require 'byebug'


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

    def count_values
        counter = Hash.new(0)
        to_n.each {|value| counter[value] += 1}
        counter
    end

    def calculate
        #returns array [pair_type_value,high_value or kicker,low_value or kicker,other kicker values in order]
        hand = to_n
        counter = count_values
        values = counter.values.sort.reverse
        case values
        when [1,1,1,1,1]                        #high card,straight,flush,straight flush,royal flush
            return [10] if royal_flush? #royal flush
            if straight? && flush?
                if hand.include?(14)
                    hand.delete(14)
                    hand << 1
                end
                return [9,hand.sort.last] #straight flush
            end
            return [6,*hand.sort.reverse] if flush? #flush
            if straight?
                if !hand.include?(13) && hand.include?(14)
                    delete(14)
                    hand << 1
                end
                return [5,hand.sort.last] #straight
            end
            return [1,*hand.sort.reverse] #high card
        when [2,1,1,1] #one pair
            return [6,*hand.sort.reverse] if flush? #flush
            return [2,*counter.select{|k,v| counter[k] == 2}.to_h.keys,
                      *counter.select{|k,v| counter[k] == 1}.to_h.keys.sort.reverse]
        when [2,2,1] #2-pairs
            return [6,*hand.sort.reverse] if flush? #flush
            return [3,*counter.select{|k,v| counter[k] == 2}.to_h.keys.sort.reverse,
                      *counter.select{|k,v| counter[k] == 1}.to_h.keys]
        when [3,1,1]#3 of a kind
            return [6,*hand.sort.reverse] if flush? #flush
            return [4,*counter.select{|k,v| counter[k] == 3}.to_h.keys,
                      *counter.select{|k,v| counter[k] == 1}.to_h.keys.sort.reverse]
        when [3,2] #full house
            return [7,*counter.select{|k,v| counter[k] == 3}.to_h.keys,
                      *counter.select{|k,v| counter[k] == 2}.to_h.keys]
        when [4,1] #four of a kind
            return [8,*counter.select{|k,v| counter[k] == 4}.to_h.keys]
        end
    end

    def beats?(hand)
        my_hand = calculate
        other_hand = hand.calculate
        paired_results = my_hand.zip(other_hand)
        paired_results.each do |my_value,other_value|
            return :win if my_value > other_value
            return :loss if other_value > my_value
        end
        return :tie
    end

    def hand_type
        hand = to_n
        counter = count_values
        values = counter.values.sort.reverse
        case values
        when [1,1,1,1,1]                        #high card,straight,flush,straight flush,royal flush
            return 'ROYAL FLUSH!' if royal_flush? #royal flush
            return 'STRAIGHT FLUSH' if straight? && flush?
            return 'FLUSH' if flush? #flush
            return 'STRAIGHT' if straight?   
            return 'HIGH CARD'
        when [2,1,1,1] #one pair
            return 'FLUSH' if flush?
            return 'ONE PAIR'
        when [2,2,1] #2-pairs
            return 'FLUSH' if flush?
            return 'TWO PAIRS'
        when [3,1,1]#3 of a kind
            return 'FLUSH' if flush?
            return 'THREE OF A KIND'
        when [3,2] #full house
            return 'FULL HOUSE'
        when [4,1] #four of a kind
            return 'FOUR OF A KIND'
        end
    end
end