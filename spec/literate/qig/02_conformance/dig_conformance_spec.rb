# frozen_string_literal: true

RSpec.describe Qig, :aggregate_failures do
  context 'it behaves like dig' do
    context 'dig documentation examples' do
      context 'Dig Methods https://ruby-doc.org/core-3.1.0/doc/dig_methods_rdoc.html' do
        subject(:item) do
          {
            id: '0001',
            type: 'donut',
            name: 'Cake',
            ppu: 0.55,
            batters: {
              batter: [
                { id: '1001', type: 'Regular' },
                { id: '1002', type: 'Chocolate' },
                { id: '1003', type: 'Blueberry' },
                { id: '1004', type: "Devil's Food" }
              ]
            },
            topping: [
              { id: '5001', type: 'None' },
              { id: '5002', type: 'Glazed' },
              { id: '5005', type: 'Sugar' },
              { id: '5007', type: 'Powdered Sugar' },
              { id: '5006', type: 'Chocolate with Sprinkles' },
              { id: '5003', type: 'Chocolate' },
              { id: '5004', type: 'Maple' }
            ]
          }
        end

        it 'satisfies the dig documentation examples' do
          expect(Qig.qig(item, :batters, :batter, 1, :type)).to eq 'Chocolate'
          expect(Qig.qig(item, :batters, :BATTER, 1, :type)).to eq nil
        end

        it 'can additionally fetch _all_ the batters' do
          expect(Qig.qig(item, :batters, :batter, [], :type))
            .to eq(['Regular', 'Chocolate', 'Blueberry', "Devil's Food"])
        end

        it 'unexpectedly can qig into integers' do
          # dig specifies "A dig method raises an exception if any receiver does not respond to #dig"

          # qig mostly just relies on receivers to respond to `[]`. Accordingly, our error is different
          expect do
            Qig.qig({ foo: 1 }, :foo, :bar)
          end.to raise_error(TypeError, 'no implicit conversion of Symbol into Integer')
          expect { Qig.qig(1, :bar) }.to raise_error(TypeError, 'no implicit conversion of Symbol into Integer')

          # So wait, this will work if we use a numeric index?
          expect(Qig.qig(1, 0)).to eq(1)
          expect(Qig.qig(1, 1)).to eq(0)
          expect(Qig.qig(0x1234, 4...12).to_s(16)).to eq('23')

          # Turns out [] is defined in a lot more places than I'd expect. Integer#[] indexes into the bitstring
          expect(0x1234.to_s(2)).to eq('1001000110100')
          expect(0x1234[4...12].to_s(16)).to eq('23')
        end

        it 'handles simple struct cases' do
          stub_const('TestStruct', Struct.new('TestStruct', :a, :b))
          expect(Qig.qig(TestStruct.new(1, 2), :a)).to eq 1
        end

        it 'handles simple OpenStruct cases' do
          require 'ostruct'
          expect(Qig.qig(OpenStruct.new(a: 1, b: 2), :a)).to eq 1 # rubocop:disable Style/OpenStructUse
        end
      end
    end
  end
end
