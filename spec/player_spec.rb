require 'rspec'
require 'player'

describe Player do
    subject(:player) {Player.new}
    describe '::initialize' do
        it 'initializes the pot' do
            player = Player.new
            pot = player.instance_variable_get(:@pot)
            expect(pot).to eq(100)
            player = Player.new(50)
            pot = player.instance_variable_get(:@pot)
            expect(pot).to eq(50)
        end

        it 'initializes the players hand' do
            hand = player.instance_variable_get(:@hand)
            expect(hand).to be_a(Hand)
        end
    end

    describe '#hand_empty?' do
        let(:hand) {instance_double(Hand)}
        context 'when hand is empty' do
            it 'returns true' do
                expect(player.hand_empty?).to be true
            end
        end
        context 'when hand is not empty' do
            it 'returns false' do
                allow(hand).to receive(:empty?).and_return(false)
                player.instance_variable_set(:@hand,hand)
                expect(player.hand_empty?).to be false
            end
        end
    end

    describe '#hand_full?' do
        let(:hand) {instance_double(Hand)}
        context 'when hand is full' do
            it 'returns true' do
                allow(hand).to receive(:full?).and_return(true)
                player.instance_variable_set(:@hand,hand)
                expect(player.hand_full?).to be true
            end
        end
        context 'when hand is not full' do
            it 'returns false' do
                allow(hand).to receive(:full?).and_return(false)
                player.instance_variable_set(:@hand,hand)
                expect(player.hand_full?).to be false
            end
        end
    end

    describe '#earn' do
        it 'adds amount to the pot' do
            player.earn(2)
            pot = player.instance_variable_get(:@pot)
            expect(pot).to eq(102)
        end
    end

    describe '#bet' do
        it 'subtracts amount from the pot' do
            player.bet(2)
            pot = player.instance_variable_get(:@pot)
            expect(pot).to eq(98)
        end

        context 'when the amount exceeds the pot'do
            it 'raises error' do
                expect{player.bet(101)}.to raise_error('Bet amount exceeds player\'s pot')
            end
        end
    end

    describe '#discard' do
        let(:hand) {instance_double(Hand)}
        it 'discards the indicated card from hand' do
            player.instance_variable_set(:@hand,hand)
            expect(hand).to receive(:discard).with(1)
            player.discard(1)
        end
    end

    describe '#receive_card' do
        let(:hand){instance_double(Hand)}
        let(:card){instance_double(Card)}
        it 'adds the passed card to hand' do
            player.instance_variable_set(:@hand,hand)
            expect(hand).to receive(:add_card).with(card)
            player.receive_card(card)
        end
    end

    describe '#discard_cards' do
        let(:card1) {instance_double(Hand)}
        let(:card2) {instance_double(Hand)}
        let(:card3) {instance_double(Hand)}

        it 'discards the cards indicated from user input' do
            allow_any_instance_of(Kernel).to receive(:gets).and_return("1,2,3\n")
            allow(player).to receive(:discard).with(3).and_return(card1)
            allow(player).to receive(:discard).with(2).and_return(card2)
            allow(player).to receive(:discard).with(1).and_return(card3)
            expect(player).to receive(:discard).with(3)
            expect(player).to receive(:discard).with(2)
            expect(player).to receive(:discard).with(1)
            player.discard_cards
        end

        it 'returns an array of the discarded cards' do
            allow_any_instance_of(Kernel).to receive(:gets).and_return("1,2,3\n")
            allow(player).to receive(:discard).with(3).and_return(card1)
            allow(player).to receive(:discard).with(2).and_return(card2)
            allow(player).to receive(:discard).with(1).and_return(card3)
            expect(player.discard_cards).to match_array([card3,card2,card1])
            allow_any_instance_of(Kernel).to receive(:gets).and_return("\n")
            expect(player.discard_cards).to match_array([])
        end

        # context 'when user input is invalid' do
        #     it 'raises error' do
        #         allow($stdin).to receive(:gets).and_return("1,2,3,4\n")
        #         expect{(player.discard_cards)}.to raise_error('Invalid input,select up to 3 cards from 1-5 separated by comma\'s')
        #         allow($stdin).to receive(:gets).and_return("1,a,3\n")
        #         expect{(player.discard_cards)}.to raise_error('Invalid input,select up to 3 cards from 1-5 separated by comma\'s')
        #         allow($stdin).to receive(:gets).and_return("1 2,3\n")
        #         expect{(player.discard_cards)}.to raise_error('Invalid input,select up to 3 cards from 1-5 separated by comma\'s')
        #         allow($stdin).to receive(:gets).and_return("1,6,3\n")
        #         expect{(player.discard_cards)}.to raise_error('Invalid input,select up to 3 cards from 1-5 separated by comma\'s')
        #     end
        # end
    end

    describe '#get_input' do
        it 'returns a symbol corresponding to user input(fold,call,raise)' do
            allow_any_instance_of(Kernel).to receive(:gets).and_return('f')
            expect(player.get_input).to eq(:f)
            allow_any_instance_of(Kernel).to receive(:gets).and_return('c')
            expect(player.get_input).to eq(:c)
            allow_any_instance_of(Kernel).to receive(:gets).and_return('r')
            expect(player.get_input).to eq(:r)
        end
    end
end