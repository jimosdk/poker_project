require_relative 'deck'
require_relative 'player'
require 'byebug'

class Game
    attr_accessor :player_turn_queue,:deck,:players
    def initialize(players = 2)
        @deck = Deck.new
        @currently_highest_bet = 0
        @active_bet = false
        @wagers = Hash.new(0)
        @folded = []
        @players = {}
        players.times {|idx| @players['Player ' + (idx + 1).to_s] = Player.new}
        @player_turn_queue = @players.keys
    end

    def round_winners(player_arr = @player_turn_queue)
        possible_winners = player_arr.select {|player| !@folded.include?(player)}
        winners = [possible_winners.pop]
        possible_winners.each do |player|  
            if @players[player].beats?(@players[winners.first]) == :win
                winners = [player]
            elsif @players[player].beats?(@players[winners.first]) == :tie
                winners << player
            end
        end
        winners
    end

    def remove_players
        @player_turn_queue.dup.each do |player|
            if @players[player].pot == 0
                @players.delete(player)
                @player_turn_queue.delete(player)
            end
        end
    end

    def game_over?
        @player_turn_queue.length == 1
    end

    def all_fold?
        @player_turn_queue.length - 1 == @folded.length
    end

    def deal(player)
        @players[player].receive_card(@deck.draw_card)
    end

    def pot_satisfied(player)
        @active_bet == true && @wagers[player] == @currently_highest_bet ||
        @active_bet == false && player == @player_turn_queue.last
    end

    def discard_round
        @player_turn_queue.each do |player|
            discarded_cards = []
            begin
                system('clear')
                discard_prompt(player)
                discarded_cards = @players[player].discard_cards
            rescue => e 
                puts e.message  
            retry  
            end
            discarded_cards.each do |card|
                deal(player)
                @deck.add_card(card)
            end
            system('clear')
            @players[player].render_hand
            sleep(3)
        end
    end

    def discard_prompt(player)
        @players[player].render_hand  
        puts 'select up to 3 cards from 1-5 separated by comma\'s'
    end

    def split_pot
        pot_caps = @wagers.values.uniq.sort
        prev = 0
        pot_caps.map! do |cap| 
            cap = cap - prev
            prev = cap + prev
            cap
        end
        eligible_players = @player_turn_queue.dup
        pot_caps.each do |cap|
            winners = round_winners(eligible_players)
            pot_amount = 0
            @wagers.each do |player,wager|
                next if wager == 0
                pot_amount += cap
                @wagers[player] -= cap
            end
            #debugger
            winners.each{|winner| @players[winner].earn(pot_amount/winners.length)}
            @wagers.each{|player,amount| eligible_players.delete(player) if amount == 0}
        end
    end


    def handle_input(player)
        loop do
            cmd = @players[player].get_input
            case cmd
            when :f 
                @folded << player
                return true
            when :c
                if @active_bet
                    call_amount = @currently_highest_bet - @wagers[player] 
                    call_amount = @players[player].pot if @players[player].pot < call_amount
                    @players[player].bet(call_amount) 
                    @wagers[player] += call_amount
                end
                return true
            when :r  
                call_amount = @currently_highest_bet - @wagers[player]
                if @players[player].pot > call_amount
                    begin
                        input = gets.chomp
                        unless input == 'q'
                            @players[player].bet(call_amount + input.to_i)
                            @wagers[player] += call_amount + input.to_i
                            @currently_highest_bet +=  input.to_i
                            @active_bet = true
                            return true
                        end
                    rescue => e  
                        puts e.message  
                    retry
                    end
                end
                
            else
                return true
            end
        end
    end













    def render_win_over
        #print eligible winners
        #print hand types
        #showcase winner
    end

    def render_earner
        #player name
        #showcase earner hand
        #handtype
    end

    def render 
        #player name
        #player hand
        #pot 
        #player pot
        #c:call amount
        #f:fold
        #r:raise
    end
end