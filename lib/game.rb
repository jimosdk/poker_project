require_relative 'deck'
require_relative 'player'

class Game
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
        player.receive_card(@deck.draw_card)
    end

    def pot_satisfied(player)
        @active_bet == true && @wagers[player] == @currently_highest_bet ||
        @active_bet == false && player == @player_turn_queue.last
    end
end