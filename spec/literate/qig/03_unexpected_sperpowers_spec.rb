# frozen_string_literal: true

RSpec.describe Qig, :aggregate_failures do
  context 'unexpected superpowers' do
    # it turns out [] is available a lot more places than I'd expect. This results
    # in unexpected and perhaps unwanted superpowers for qig.
    #
    # Since these behaviors are unexpected, consider them unspecified for now.
    # Qig MAY in the future decide to change the behavior.
    #
    # At the moment it seems like these behaviors would mostly be useful, because
    # they allow us to qig into more things.
    #
    # BUT because they result in fewer errors, they might turn out to be footguns
    # due to unexpected behaviors down the line.
    #
    # They also technically make the flattening behavior of [] inconsistent compared
    # to regular indexing.

    describe 'String#[]' do
      it 'indexes into the string' do
        expect('abcdefghijklmnopqrstuvwxyz'[12]).to eq('m')
        expect('the quick brown fox'[4...9]).to eq('quick')
      end

      # could be potentially useful
      specify 'qig can qig into strings' do
        expect(Qig.qig(%w[abcd 1234 xyzw], [], 1)).to eq(%w[b 2 y])
        expect(Qig.qig(%w[abcd 1234 xyzw], [], 1..2)).to eq(%w[bc 23 yz])
      end

      # or could be unexpected
      specify 'qig indexes into the string in mixed array-string contexts' do
        expect(Qig.qig([[1, 2], 'abc', %w[foo bar baz]], [], 1)).to eq([2, 'b', 'bar'])
      end
      # jq would raise an error in this case, so the main downside of this unexpected case
      # is that qig might be considered to fail too slowly.
      #
      # Given that... I'm inclined to keep it. Flexibility over safety. In the spirit of dig?
      #
      # Still on the fence, but let's keep it and see how it goes.

      specify 'value iteration is now technically inconsistent, but I think still intuitive' do
        # according to the strict jq definition of "value iteration", value iteration should
        # produce a list of all possible values of `subject[key]` for a given subject.
        #
        # In Qig, strings are indexable but not splattable.
        expect(Qig.qig('abc', [])).not_to eq(%w[a b c])

        # I think this inconsistency is fine and intuitive.
        # In particular, it keeps [] more in line with our intuition on flatten
        expect(Qig.qig(['abc', %w[one two three]], [], [])).to eq(%w[abc one two three])

        # the alternative is horrifying
        expect(Qig.qig(['abc', %w[one two three]], [], [])).not_to eq(%w[a b c one two three])
      end
    end

    describe 'Integer#[]' do
      it 'indexes into the binary representation of a number' do
        expect(0xdcba[0...4]).to   eq(0xa)
        expect(0xdcba[4...8]).to   eq(0xb)
        expect(0xdcba[8...12]).to  eq(0xc)
        expect(0xdcba[12...16]).to eq(0xd)
        expect(0xdcba[16...20]).to eq(0x0)
        expect(0xdcba[4...12]).to  eq(0xcb)
        expect(0xdcba[0...8]).to   eq(0xba)
      end

      specify 'qig inherits this power, for better or for worse' do
        expect(Qig.qig([0xabcd, 0x1234], [], 8...16)).to eq([0xab, 0x12])
        expect(Qig.qig([0xabcd, 0x1234, 'the quick brown fox'], [], 8...16)).to eq([0xab, 0x12, 'k brown '])
      end
      # Going with the same reasoning as for strings: since this would be an error case for jq,
      # keep the behavior for now and see how much of a footgun it turns out to be.
    end
  end
end
