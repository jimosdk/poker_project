require 'rspec'
require 'deck'

describe Deck do
    subject(:deck) {Deck.new}
    describe '::initialize' do
        it 'creates an queue(array) instance variable' do
            expect(deck.queue).to be_an(Array)
        end

        it 'queue should contain 52 elements' do
            expect(deck.queue.length).to eq(52)
        end

        it 'each element should be an instance of Card class' do
            deck.queue.each {|card| expect(card.is_a?(Card)).to be_truthy}
        end

        it 'each card should be a unique combination of value/suit' do
            unique_cards = deck.queue.each_with_object([]){|card,card_array| card_array << card.to_s.uncolorize}.uniq
            expect(unique_cards.length).to eq(52)
            product = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'].product(['♠','♥','♣','♦'])
            product.map!(&:join)
            expect(unique_cards).to match_array(product)
        end
    end

    describe '#draw_card' do
        context 'when the deck is not empty' do
            it 'removes a card from the queue' do
                deck.draw_card
                expect(deck.queue.length).to eq(51)
            end

            it 'removes a card from the front of the queue' do
                front_card = deck.queue.last
                deck.draw_card
                expect(deck.queue).to_not include(front_card)
            end

            it 'returns a card from the front of the queue' do
               front_card = deck.queue.last
               expect(deck.draw_card).to eq(front_card)
            end
        end

        context 'when the deck is empty' do
            it 'returns nil' do
                deck.instance_variable_set(:@queue,[])
                expect(deck.draw_card).to be_nil
            end
        end
    end

    describe '#empty?' do
        it 'calls empty? on queue' do 
            expect(deck.queue).to receive(:empty?)
            deck.empty?
        end

        context 'when the queue is empty' do
            it 'returns true' do
                deck.instance_variable_set(:@queue,[])
                expect(deck.empty?).to be true
            end
        end

        context 'when the queue is not empty' do
            it 'returns false' do
                expect(deck.empty?).to be false
            end
        end
    end

    describe '#add_card' do
        let(:card){[]}
        let(:card2){[1]}
        it 'takes one argument' do
            allow(card).to receive(:is_a?).and_return(true)
            expect{deck.add_card(card)}.to_not raise_error(ArgumentError)
        end

        context 'if card is not instance of Card' do
            it 'raises an error'  do
                deck.instance_variable_get(:@queue).pop
                expect{deck.add_card(2)}.to raise_error('Invalid argument for card')
            end
        end

        context 'if deck is full' do
            it 'raises an error' do
                allow(card).to receive(:is_a?).and_return(true)
                expect{deck.add_card(card)}.to raise_error('Deck is full')
            end
        end

        context 'when deck is not full' do
            it 'adds the card to the queue' do
                allow(card).to receive(:is_a?).and_return(true)
                allow(card2).to receive(:is_a?).and_return(true)
                deck.instance_variable_get(:@queue).pop
                deck.instance_variable_get(:@queue).pop
                deck.add_card(card)
                expect(deck.queue.length).to eq(51)
                deck.add_card(card2)
                expect(deck.queue.length).to eq(52)
            end

            it 'adds the card at the back of the queue' do
                allow(card).to receive(:is_a?).and_return(true)
                deck.instance_variable_get(:@queue).pop
                deck.add_card(card)
                expect(deck.queue.first).to be(card)
            end

            it 'does not add a duplicate card' do
                allow(card).to receive(:is_a?).and_return(true)
                deck.instance_variable_get(:@queue).pop
                deck.instance_variable_get(:@queue).pop
                deck.add_card(card)
                expect{deck.add_card(card)}.to raise_error("Can not add duplicate card")
            end
        end
    end

    describe '#full?' do 
        context 'when the deck is full' do
            it 'returns true' do
                expect(deck.full?).to be true
            end
        end

        context 'when the deck is not full' do
            it 'returns false' do
                deck.draw_card
                expect(deck.full?).to be false
            end
        end
    end

    describe '#shuffle!' do
        it 'calls shuffle! on the queue' do
            expect(deck.queue).to receive(:shuffle!)
            deck.shuffle!
        end
    end
end