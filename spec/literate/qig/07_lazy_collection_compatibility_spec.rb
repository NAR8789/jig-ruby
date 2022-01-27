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
    end

    # that probably means if I really want qig to be general, I should use `flat_map` instead of `flatten`

    it 'supports [],[] on lazy collections' do
      expect(Qig.qig([[1, 2], [3, 4]].lazy, [], []).to_a).to eq([1, 2, 3, 4])

      # indeed, this fails if ([] is implemented as flatten(1))[https://github.com/NAR8789/qig-ruby/pull/12/commits/494f7b794abebf1fdddd8f35219381689bc992c2]
    end

    # I think that's all we really need for full compatibility, since the only other method we need is `map`.
    # Given an Enumerator::Lazy as top-level collection, qig should now be able to stream like jq does.

    it 'can operate in streaming fashion, given a lazy enumerator as top-level collection'
  end
end
