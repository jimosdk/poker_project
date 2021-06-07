require_relative 'hand'



class Player
    attr_reader :hand,:pot
    def initialize(pot = 100)
        @hand = Hand.new
        @pot = pot
    end

    def hand_empty?
        @hand.empty?
    end

    def hand_full?
        @hand.full?
    end

    def to_s
        @hand.to_s
    end

    def earn(amount)
        @pot += amount
    end

    def bet(amount)
        raise 'Bet amount exceeds player\'s pot' if @pot - amount < 0
        @pot -= amount
    end

    def discard(num)
        @hand.discard(num)
    end

    def receive_card(card)
        @hand.add_card(card)
    end

    def discard_cards
        begin 
            input = gets.chomp
            input = parse_discard(input)
        rescue => e
            puts e.message
        retry
        end

        input.sort.reverse.map{|card| discard(card)}
    end

    def parse_discard(input)
        input = input.split(",")
        unless input.length.between?(0,3) && input.all?{|ele| ele.to_i.to_s == ele}
        raise 'Invalid input,select up to 3 cards from 1-5 separated by comma\'s' 
        end
        input.map!(&:to_i)
        unless input.all?{|ele| ele.between?(1,5)}
        raise 'Invalid input,select up to 3 cards from 1-5 separated by comma\'s'
    end
        input
    end

    def get_input(uncalled_bet)
        loop do
            puts "uncalled bet : #{uncalled_bet}"
            puts "your pot : #@pot"
            input = gets.chomp

            case input
            when 'f' 
                return :f
            when 'c'  
                return :c
            when 'r'
                if @pot > uncalled_bet
                    begin
                        puts 'Input bet amount or hit enter to cancel'
                        bet_amount = gets.chomp 
                        if input != '' 
                            bet(bet_amount.to_i + uncalled_bet)
                            return bet_amount.to_i
                        end
                    rescue => e 
                        puts e.message
                    retry
                    end  
                else
                    puts 'Not enough chips'
                end
            else
                puts 'Invalid input'
            end
        end
    end

    def beats?(player)
        @hand.beats?(player.hand)
    end
end