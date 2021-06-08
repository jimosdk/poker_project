require_relative 'deck'
require_relative 'player'

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

    def round_winners
        possible_winners = @player_turn_queue.select {|player| !@folded.include?(player)}
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
end