require 'rspec'
require 'game'

describe Game do
    subject(:game){Game.new}
    describe '::initialize' do
        
        it 'initializes the currently_highest_bet to 0' do
            bet = game.instance_variable_get(:@currently_highest_bet)
            expect(bet).to eq(0)
        end

        it 'initializes active bet to false' do
            active_bet = game.instance_variable_get(:@active_bet)
            expect(active_bet).to be false
        end
        it 'initializes players as a hash containing all the player instances' do
            players = game.instance_variable_get(:@players)
            expect(players).to be_a(Hash)
            expect(players.length).to eq(2)
            expect(players['Player 1']).to be_a(Player)
            expect(players['Player 2']).to be_a(Player)
        end

        it 'initializes a new deck' do
            deck = game.instance_variable_get(:@deck)
            expect(deck).to be_a(Deck)
        end

        it 'initializes an array with players in an order that denotes their turn ' do
            turns = game.instance_variable_get(:@player_turn_queue)
            expect(turns).to eq(['Player 1','Player 2'])
        end

        it 'initializes folding player\'s array to empty' do
            folded = game.instance_variable_get(:@folded)
            expect(folded).to be_an(Array)
            expect(folded).to eq([])
        end

        it 'initializes wagers to an empty hash' do
            wagers = game.instance_variable_get(:@wagers)
            expect(wagers).to be_a(Hash)
        end
    end

    describe '#round_winners' do
        subject(:game){Game.new(5)}
        let(:player1){instance_double(Player)}
        let(:player2){instance_double(Player)}
        let(:player3){instance_double(Player)}
        let(:player4){instance_double(Player)}
        let(:player5){instance_double(Player)}
        let(:folded){[]}
        it 'determines the winners of a single round' do
            game.instance_variable_set(:@folded,folded)
            game.instance_variable_set(:@player_turn_queue,['Player 1','Player 2','Player 3','Player 4','Player 5'])
            game.instance_variable_set(:@players,{'Player 1' => player1,
                                                  'Player 2' => player2,
                                                  'Player 3' => player3,
                                                  'Player 4' => player4,
                                                  'Player 5' => player5})
            allow(folded).to receive(:include?).with('Player 1').and_return(true)
            allow(folded).to receive(:include?).with('Player 2').and_return(false)
            allow(folded).to receive(:include?).with('Player 3').and_return(true)
            allow(folded).to receive(:include?).with('Player 4').and_return(false)
            allow(folded).to receive(:include?).with('Player 5').and_return(false)

            allow(player2).to receive(:beats?).with(player5).and_return(:loss)
            allow(player4).to receive(:beats?).with(player5).and_return(:tie)
            expect(game.round_winners).to eq(['Player 5','Player 4'])
            allow(player4).to receive(:beats?).with(player5).and_return(:win)
            expect(game.round_winners).to eq(['Player 4'])
            allow(player2).to receive(:beats?).with(player5).and_return(:win)
            allow(player4).to receive(:beats?).with(player2).and_return(:loss)
            expect(game.round_winners).to eq(['Player 2'])
            allow(player2).to receive(:beats?).with(player5).and_return(:tie)
            allow(player4).to receive(:beats?).with(player5).and_return(:tie)
            expect(game.round_winners).to eq(['Player 5','Player 2','Player 4'])
            allow(player2).to receive(:beats?).with(player5).and_return(:tie)
            allow(player4).to receive(:beats?).with(player5).and_return(:loss)
            expect(game.round_winners).to eq(['Player 5','Player 2'])
            allow(player2).to receive(:beats?).with(player5).and_return(:tie)
            allow(player4).to receive(:beats?).with(player5).and_return(:win)
            expect(game.round_winners).to eq(['Player 4'])
        end
    end
    
    describe '#remove_players' do
        it 'removes players with empty pot from the game' do
            players = game.instance_variable_get(:@players)
            player1 = players['Player 1']
            player2 = players['Player 2']
            allow(player1).to receive(:pot).and_return(0)
            allow(player2).to receive(:pot).and_return(1)
            game.remove_players
            players = game.instance_variable_get(:@players)
            player_turns = game.instance_variable_get(:@player_turn_queue)
            expect(players).to eq({'Player 2' => player2})
            expect(player_turns).to eq(['Player 2'])
        end
    end

    describe '#game_over?' do
    
        context 'when there is only one player remaining in the game' do
            it 'returns true ' do
                game.instance_variable_set(:@player_turn_queue,['Player 1'])
                expect(game.game_over?).to be true
            end
        end

        context 'when there are more than one player remaining in the game' do
            it 'returns false' do
                expect(game.game_over?).to be false
            end
        end
    end

    describe '#all_fold?' do
        context 'when there is only one player who hasn\'t folded' do
            it 'returns true' do
                game.instance_variable_set(:@folded,['Player 1'])
                expect(game.all_fold?).to be true
            end
        end

        context 'when there are more than one player who hasn\'t folded' do
            it 'returns false' do
                expect(game.all_fold?).to be false
            end
        end
    end

    describe '#deal' do
        let(:player1) {instance_double(Player)}
        let(:card){instance_double(Card)}
        it 'deals one card to the player passed as argument' do
            deck = game.instance_variable_get(:@deck)
            game.instance_variable_set(:@players,{'Player 1' => player1})
            allow(deck).to receive(:draw_card).and_return(card)
            allow(player1).to receive(:receive_card).and_return(card)
            expect(game.deal('Player 1')).to eq(card)
        end
    end

    describe '#pot_satisfied' do

        context 'when the last player has finished his round and no player raised the pot' do
            it 'returns true' do
                expect(game.pot_satisfied('Player 2')).to be true
                expect(game.pot_satisfied('Player 1')).to be false
            end
        end

        context 'when its the turn of the initial better and the pot hasn\'t been raised again' do
            it 'returns true' do
                game.instance_variable_set(:@active_bet,true)
                game.instance_variable_set(:@currently_highest_bet,70)
                game.instance_variable_set(:@wagers,{'Player 1' => 70, 'Player 2' => 30})
                expect(game.pot_satisfied('Player 1')).to be true
                expect(game.pot_satisfied('Player 2')).to be false
            end
        end
    end

    describe '#discard_round' do
        let(:deck) {instance_double('Deck')}
        let(:card) {instance_double('Card')}
        let(:player1){instance_double('Player')}
        let(:player2){instance_double('Player')}
        let(:player3){instance_double('Player')}
        it 'adds discards to deck and refills each players hand to an equal amount' do
            game.instance_variable_set(:@deck,deck)
            game.instance_variable_set(:@player_turn_queue,['Player 1','Player 2','Player 3'])
            game.instance_variable_set(:@players,{'Player 1' => player1,'Player 2' =>player2,'Player 3' => player3})
            allow(player1).to receive(:discard_cards).and_return([card,card,card])
            allow(player2).to receive(:discard_cards).and_return([card,card])
            allow(player3).to receive(:discard_cards).and_return([])
            allow(deck).to receive(:add_card).with(card)
            allow(deck).to receive(:draw_card).and_return(card)
            allow(player1).to receive(:receive_card).with(card)
            allow(player2).to receive(:receive_card).with(card)
            allow(player1).to receive(:render_hand)
            allow(player2).to receive(:render_hand)
            allow(player3).to receive(:render_hand)
            expect(player1).to receive(:discard_cards).once
            expect(player2).to receive(:discard_cards).once
            expect(player3).to receive(:discard_cards).once
            expect(deck).to receive(:add_card).with(card).exactly(5).times
            expect(deck).to receive(:draw_card).and_return(card).exactly(5).times
            expect(player1).to receive(:receive_card).with(card).exactly(3).times
            expect(player2).to receive(:receive_card).with(card).exactly(2).times
            expect(player3).to_not receive(:receive_card)
            game.discard_round
        end
    end
end