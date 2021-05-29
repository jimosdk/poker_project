require 'rspec'
require 'card'

describe Card do
    subject(:card) {Card.new('A',:pike)}

    describe '::values' do
        it 'returns an array' do
            expect(Card.values).to be_an(Array)
        end

        it 'returned array contains all legal values' do
            expect(Card.values).to match_array(['2','3','4','5','6','7','8','9','10','J','Q','K','A'])
        end
    end

    describe '::suits' do
        it 'returns an array' do
            expect(Card.suits).to be_an(Array)
        end

        it 'returned array contains all legal suit symbols' do
            expect(Card.suits).to match_array([:pike,:heart,:sword,:tile])
        end
    end

    describe '::initialize' do
        it 'takes two arguments,a value and a suit' do
            expect{Card.new('A',:pike)}.to_not raise_error
            expect{Card.new('A')}.to raise_error(ArgumentError)
            expect{Card.new('A',:pike,1)}.to raise_error(ArgumentError)
        end

        it 'initializes a value instance variable' do
            expect(card.value).to eq('A')
        end

        it 'initializes a suit instance variable' do
            expect(card.suit).to eq('♠')
        end

       context 'when value is not string' do
            it 'raises an error' do
                expect{Card.new(1,:pike)}.to raise_error('Argument value must be a string')
            end
        end

        context 'when value is not a valid character' do
            it 'raises an error' do
                expect{Card.new('H',:pike)}.to raise_error('Invalid character for argument value')
            end
        end

        context 'when suit is not symbol' do
            it 'raises an error' do
                expect{Card.new('A',2)}.to raise_error('Argument suit must be a symbol')
            end
        end

        context 'when suit is not a valid character' do
            it 'raises an error' do
                expect{Card.new('A',:sord)}.to raise_error('Invalid symbol for argument suit')
            end
        end

    end

    describe '#to_s' do
        it 'returns a visual representation of a card in string format' do
            expect(card.to_s).to be_a(String)
        end

        it 'the returned string must be 2 characters long' do
            expect(card.to_s.uncolorize.length).to eq(2)
        end

        it 'the first character should be the value of the card' do
            expect(card.to_s.uncolorize[0]).to eq(card.value) 
        end

        it 'the second character should be the suit of the card' do
            expect(card.to_s.uncolorize[1]).to eq(card.suit) 
        end
    end
end