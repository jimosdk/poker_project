require_relative 'deck'
require_relative 'player'
require 'byebug'

class Game
    attr_accessor :player_turn_queue,:deck,:players,:active_bet,:wagers,:currently_highest_bet,:folded
    def initialize(players = 2,ante = 5)
        @deck = Deck.new
        @ante = ante
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
        @active_bet == false && player == @player_turn_queue.first
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
        puts player
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
            winners.each do |winner| 
                system('clear')
                @players[winner].earn(pot_amount/winners.length)
                render_player_status(winner,true,true,pot_amount/winners.length)
                sleep(3)
            end
            @wagers.each{|player,amount| eligible_players.delete(player) if amount == 0}
        end
    end


    def handle_input(player)
        loop do
            call_amount = @currently_highest_bet - @wagers[player]
            system('clear')
            render_player_status(player,false,true,nil,true)
            puts 'f : fold'
            if call_amount == 0 
                puts "c : check"
            else
                puts "c : call #{call_amount}"
            end
            puts "r : raise"
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
                    system('clear')
                    render_player_status(player,false,true,nil,true)
                    puts 'input raise amount'
                    puts 'q: cancel raise'
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

    def initialize_parameters
        @folded = []
        @active_bet = false
        @wagers = Hash.new(0)
        @currently_highest_bet = 0
    end


    def play
        until game_over?
            3.times{@deck.shuffle!}
            @currently_highest_bet = @ante
            @player_turn_queue.each do |player|
                begin 
                    @players[player].bet(@ante)
                    @wagers[player] += @ante
                rescue 
                    @wagers[player] += @players[player].pot 
                    @players[player].bet(@players[player].pot)
                end
            end
            i = 0
            until @player_turn_queue.all?{|player| @players[player].hand_full?}
                deal(@player_turn_queue[i])
                i = (i+1)% @player_turn_queue.length
            end
            i = 0
            loop do 
                cur_player = @player_turn_queue[i]
                if @folded.include?(cur_player)
                    i = (i+1)% @player_turn_queue.length
                    break if pot_satisfied(@player_turn_queue[i])
                    next  
                end
                handle_input(cur_player)
                i = (i+1)% @player_turn_queue.length
                break if pot_satisfied(@player_turn_queue[i])
            end

            @active_bet = false
            discard_round

            i = 0
            loop do 
                cur_player = @player_turn_queue[i]
                if @folded.include?(cur_player)
                    i = (i+1)% @player_turn_queue.length
                    break if pot_satisfied(@player_turn_queue[i])
                    next  
                end
                handle_input(cur_player)
                i = (i+1)% @player_turn_queue.length
                break if pot_satisfied(@player_turn_queue[i])
            end

            system('clear')
            render_win_over
            split_pot

            initialize_parameters
            i = 0
            until @player_turn_queue.all?{|player| @players[player].hand_empty?}
                player = @player_turn_queue[i]
                deck.add_card(@players[player].discard(1))
                i = (i+1)% @player_turn_queue.length
            end
            @player_turn_queue.rotate!
            remove_players
        end
        system('clear')
        puts @player_turn_queue.first + ' wins!'
    end








    def render_win_over
        @player_turn_queue.each do |player|
            next if @folded.include?(player)
            render_player_status(player,true)
            sleep(2)
        end
        sleep(2)
        system('clear')
        puts "      ROUND WINNERS"
        round_winners.each {|winner| render_player_status(winner,true)}
        sleep(3.5)
    end

    def render_player_status(player,handtype = false,player_pot = false,earnings = nil,pot = false)
        puts player
        p = @players[player]
        p.render_hand
        puts "       " + p.hand_type if handtype
        print player + '\'s pot : ' + "#{p.pot}"  if player_pot
        if earnings.nil?
            puts
        else
            puts " ( +#{earnings} )"
        end
        puts "Main pot : " + wagers.values.sum.to_s if pot 
    end
end