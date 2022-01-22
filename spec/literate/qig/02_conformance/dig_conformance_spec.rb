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
          test_struct = Struct.new('TestStruct', :a, :b)
          expect(Qig.qig(test_struct.new(1, 2), :a)).to eq 1
        end

        it 'handles simple OpenStruct cases' do
          require 'ostruct'
          expect(Qig.qig(OpenStruct.new(a: 1, b: 2), :a)).to eq 1 # rubocop:disable Style/OpenStructUse
        end
      end

      context 'Hash#dig https://ruby-doc.org/core-3.1.0/Hash.html#method-i-dig' do
        it 'matches dig on nested hashes' do
          h = { foo: { bar: { baz: 2 } } }
          expect(Qig.qig(h, :foo)).to eq({ bar: { baz: 2 } })
          expect(Qig.qig(h, :foo, :bar)).to eq({ baz: 2 })
          expect(Qig.qig(h, :foo, :bar, :baz)).to eq(2)
          expect(Qig.qig(h, :foo, :bar, :BAZ)).to eq(nil)
        end

        it 'matches dig on nested hashes and arrays' do
          h = { foo: { bar: %i[a b c] } }
          expect(Qig.qig(h, :foo, :bar, 2)).to eq(:c)
        end

        it 'matches dig on default values for keys that are not present' do
          h = { foo: { bar: %i[a b c] } }
          expect(Qig.qig(h, :hello)).to eq(nil)

          h.default_proc = ->(hash, _key) { hash }
          expect(Qig.qig(h, :hello, :world)).to eq(h)
          expect(Qig.qig(h, :hello, :world, :foo, :bar, 2)).to eq(:c)
        end
      end

      context 'Array#dig https://ruby-doc.org/core-3.1.0/Array.html#method-i-dig' do
        it 'matches dig on nested arrays' do
          a = [:foo, [:bar, :baz, %i[bat bam]]]
          expect(Qig.qig(a, 1)).to eq([:bar, :baz, %i[bat bam]])
          expect(Qig.qig(a, 1, 2)).to eq(%i[bat bam])
          expect(Qig.qig(a, 1, 2, 0)).to eq(:bat)
          expect(Qig.qig(a, 1, 2, 3)).to eq(nil)
        end
      end

      context 'Struct#dig https://ruby-doc.org/core-3.1.0/Struct.html#method-i-dig' do
        let(:foo) { Struct.new(:a) }
        subject(:f) do
          foo.new(foo.new({ b: [1, 2, 3] }))
        end

        it 'matches dig on string or symbol arguments' do
          expect(Qig.qig(f, :a)).to eq(foo.new({ b: [1, 2, 3] }))
          expect(Qig.qig(f, :a, :a)).to eq({ b: [1, 2, 3] })
          expect(Qig.qig(f, :a, :a, :b)).to eq([1, 2, 3])
          expect(Qig.qig(f, :a, :a, :b, 0)).to eq(1)
          expect(Qig.qig(f, :b, 0)).to eq(nil)
        end

        it 'matches dig on integer arguments' do
          expect(Qig.qig(f, 0)).to eq(foo.new({ b: [1, 2, 3] }))
          expect(Qig.qig(f, 0, 0)).to eq({ b: [1, 2, 3] })
          expect(Qig.qig(f, 0, 0, :b)).to eq([1, 2, 3])
          expect(Qig.qig(f, 0, 0, :b, 0)).to eq(1)
          expect(f.dig(1, 0)).to eq(nil) # correction to doc example (original repeats f.dig(:b, 0) from above)
          expect(Qig.qig(f, 1, 0)).to eq(nil)
        end
      end

      context 'OpenStruct#dig https://ruby-doc.org/stdlib-3.1.0/libdoc/ostruct/rdoc/OpenStruct.html#method-i-dig' do
        it 'matches dig' do
          require 'ostruct'
          address = OpenStruct.new('city' => 'Anytown NC', 'zip' => 12_345)       # rubocop:disable Style/OpenStructUse
          person  = OpenStruct.new('name' => 'John Smith', 'address' => address)  # rubocop:disable Style/OpenStructUse
          expect(Qig.qig(person, :address, 'zip')).to eq(12_345)
          expect(Qig.qig(person, :business_address, 'zip')).to eq(nil)
        end
      end

      context 'CSV::Row#dig https://ruby-doc.org/stdlib-3.1.0/libdoc/csv/rdoc/CSV/Row.html#method-i-dig' do
        it 'matches dig' do
          require 'csv'
          source = "Name,Value\nfoo,0\nbar,1\nbaz,2\n"
          table = CSV.parse(source, headers: true)
          row = table[0]
          expect(Qig.qig(row, 1)).to eq('0')
          expect(Qig.qig(row, 'Value')).to eq('0')
          expect(Qig.qig(row, 5)).to eq(nil)
        end
      end

      context 'CSV::Table#dig https://ruby-doc.org/stdlib-3.1.0/libdoc/csv/rdoc/CSV/Table.html#method-i-dig' do
        it 'Extracts the nested value specified by the sequence of index or header objects'
      end
    end
  end
end
