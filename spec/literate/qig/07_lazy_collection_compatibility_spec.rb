# frozen_string_literal: true

RSpec.describe Qig, :aggregate_failures do
  describe 'lazy collection compatibility' do
    # see also: (Qig::Qiggable compatibility with .lazy)[qiggable/01_dotlazy_compatibility_spec.rb]

    specify 'Enumerator::Lazy supports #map and #flat_map but not #flatten or #[]' do
      expect(Enumerator::Lazy.method_defined?(:map)).to eq(true)
      expect(Enumerator::Lazy.method_defined?(:flat_map)).to eq(true)
      expect(Enumerator::Lazy.method_defined?(:flatten)).to eq(false)
      expect(Enumerator::Lazy.method_defined?(:[])).to eq(false)

      expect(Enumerator::Lazy.method_defined?(:values)).to eq(false)
    end

    specify 'more generally... Enumerable supports #map and #flat_map but not #[] or #flatten' do
      expect(Enumerable.method_defined?(:map)).to eq(true)
      expect(Enumerable.method_defined?(:flat_map)).to eq(true)
      expect(Enumerable.method_defined?(:flatten)).to eq(false)
      expect(Enumerable.method_defined?(:[])).to eq(false)

      expect(Enumerator::Lazy.method_defined?(:values)).to eq(false)

      # so everything in this document should also be valid for applying qig to Enumerables.
    end

    # that probably means if I really want qig to be general, I should use `flat_map` instead of `flatten`

    it 'supports [],[] on lazy collections' do
      expect(Qig.qig([[1, 2], [3, 4]].lazy, [], []).to_a).to eq([1, 2, 3, 4])

      # indeed, this fails if ([] is implemented as flatten(1))[https://github.com/NAR8789/qig-ruby/pull/12/commits/494f7b794abebf1fdddd8f35219381689bc992c2]
    end

    # I think that's all we really need for full compatibility, since the only other method we need is `map`.
    # Given an Enumerator::Lazy as top-level collection, qig should now be able to stream like jq does.

    it 'can operate in streaming fashion, given a lazy enumerator as top-level collection'

    describe 'stepping' do
      # of course, indexing into lazy enumerators is obviously unsupported, because they don't support
      # [] or slice.
      #
      # Though... couldn't I implement this with drop?

      it 'can index into lazy enumerators' do
        expect(Qig.qig(('a'..).lazy, 10)).to eq('k')
      end

      it 'can slice into lazy enumerators by range' do
        expect(Qig.qig(('a'..).lazy, 10..15).to_a).to eq(%w[k l m n o p])
        expect(Qig.qig(('a'..).lazy, 10...15).to_a).to eq(%w[k l m n o])
        expect(Qig.qig(('a'..).lazy, 10..8).to_a).to eq([])
      end

      it 'does NOT support negative indexes' do
        expect { Qig.qig(('a'..).lazy, -1) }.to raise_error(ArgumentError, 'attempt to drop negative size')
        expect { Qig.qig(('a'..'z').lazy, -1) }.to raise_error(ArgumentError, 'attempt to drop negative size')

        expect(Qig.qig(('a'..'z').lazy, 4..-1).to_a).to eq []

        expect { Qig.qig(('a'..'z').lazy, -4..-1) }.to raise_error(ArgumentError, 'attempt to drop negative size')
      end
    end
  end
end
