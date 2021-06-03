require 'rspec'
require 'hand'

describe Hand do
    subject(:hand) {Hand.new}
    let(:card){instance_double('Card',:value => 'A',:suit => '♠')}
    let(:card2){instance_double('Card2',:value => 'K',:suit => '♠')}
    let(:card3){instance_double('Card3',:value => 'Q',:suit => '♠')}
    let(:card4){instance_double('Card4',:value => 'J',:suit => '♠')}
    let(:card5){instance_double('Card5',:value => '10',:suit => '♠')}
    describe '::initialize' do
        it 'initializes instance attribute cards to empty array' do
            cards = hand.instance_variable_get(:@cards)
            expect(cards).to match_array([])
        end
    end

    describe '#empty?' do
        context 'if there are no cards in hand' do
            it 'returns true' do
                expect(hand.empty?).to be true
            end
        end

        context 'if there are cards in hand' do
            it 'returns false' do
                hand.instance_variable_set(:@cards,[card])
                expect(hand.empty?).to be false
            end
        end
    end

    describe '#full?' do
        context 'if there are 5 cards in hand' do
            it 'returns true' do
                hand.instance_variable_set(:@cards,[card,card,card,card,card])
                expect(hand.full?).to be true
            end
        end

        context 'if there are less than 5 cards in hand' do
            it 'returns false' do
                expect(hand.full?).to be false
            end
        end
    end

    describe '#add_card' do
        before (:example) do
            allow(card).to receive(:is_a?).with(Card).and_return(true)
        end
        it 'receives one argument' do
            expect{hand.add_card(card)}.to_not raise_error(ArgumentError)
        end

        it 'raises error if argument is not of type Card' do
            expect{hand.add_card(card)}.to_not raise_error('Argument is not a card')
            expect{hand.add_card('A')}.to raise_error('Argument is not a card')
        end

        context 'if the hand if not full' do
            it 'adds card to the hand' do
                hand.add_card(card)
                cards = hand.instance_variable_get(:@cards)
                expect(cards).to match_array([card])
            end
        end

        context 'if the hand is full' do
            it 'raises error' do
                hand.instance_variable_set(:@cards,[card,card,card,card,card])
                expect{hand.add_card(card)}.to raise_error('Hand is full')
            end
        end
    end

    describe '#discard' do
        before(:example) do
            hand.instance_variable_set(:@cards,[card,card2,card3])
        end
        it 'receives one argument' do
            expect{hand.discard(1)}.to_not raise_error(ArgumentError)
        end

        context'when argument is not an integer' do
            it 'raises error' do
                expect{hand.discard('a')}.to raise_error('Argument does not indicate a card on hand')
            end
        end
        context 'if the hand is not empty' do
            it 'discards a card from hand' do
                hand.discard(1)
                cards = hand.instance_variable_get(:@cards)
                expect(cards.length).to eq(2)
            end

            it 'discards the chosen card from hand' do
                hand.discard(2)
                cards = hand.instance_variable_get(:@cards)
                expect(cards).to_not include(card2)
                hand.discard(1)
                cards = hand.instance_variable_get(:@cards)
                expect(cards).to_not include(card)
                hand.discard(1)
                cards = hand.instance_variable_get(:@cards)
                expect(cards).to_not include(card3)
                
            end

            it 'returns the discarded card' do
                expect(hand.discard(3)).to be(card3)
                expect(hand.discard(2)).to be(card2)
                expect(hand.discard(1)).to be(card)
            end
        end

        context 'if the hand is empty' do
            it 'raises error' do
                3.times {hand.discard(1)}
                expect{hand.discard(1)}.to raise_error('No cards in hand')
            end
        end
    end
end