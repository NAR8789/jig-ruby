# frozen_string_literal: true

RSpec.describe Qig do
  it 'has a version number' do
    expect(Qig::VERSION).not_to be nil
  end

  describe '#qig', :aggregate_failures do
    it 'handles trivial cases' do
      expect(Qig.qig({})).to eq({})
      expect(Qig.qig([])).to eq([])
    end

    it 'handles simple hash cases' do
      expect(Qig.qig({a: 1, b: 2}, :a)).to eq(1)
      expect(Qig.qig({a: 1, b: 2}, :b)).to eq(2)
      expect(Qig.qig({a: 1, b: 2}, :c)).to eq(nil)
      expect(Qig.qig({a: 1, b: 2}, :c, :d)).to eq(nil)
    end

    it 'handles simple array cases' do
      expect(Qig.qig([1, 2], 0)).to eq(1)
      expect(Qig.qig([1, 2], 1)).to eq(2)
      expect(Qig.qig([1, 2], 2)).to eq(nil)
      expect(Qig.qig([1, 2], 2, 0)).to eq(nil)

      # this last example is interesting... what if we want to 
    end

    describe '[]' do
      it 'treats the first level of [] as array descent' do
        expect(Qig.qig([[1, 2], [3, 4]], [])).to eq([[1, 2], [3, 4]])
        expect(Qig.qig([[1, 2], [3, 4]], [], 0)).to eq([1, 3])
        expect(Qig.qig([[1, 2], [3, 4]], [], 1)).to eq([2, 4])
        expect(Qig.qig([[1, 2], [3, 4]], [], 2)).to eq([nil, nil])
        expect(Qig.qig([[1, 2], [3, 4]], [], 2, 0)).to eq([nil, nil])
      end

      it 'unboxes top level collections' do
        expect(Qig.collection_qig([[1, 2], [3, 4]], [])).to eq([1, 2, 3, 4])
      end

      it 'preserves atoms' do
        expect(Qig.collection_qig([1, 2], [])).to eq([1, 2])
        expect(Qig.collection_qig([[1, 2], 3, [4, 5]], [])).to eq([1, 2, 3, 4, 5])
      end
      
      # But there's some ambiguity here: shouldn't the outer enclosing 
      # 

      it 'treats the second level of [] as flattening' do
        # in jq, [] unboxes top-level arrays

        expect(Qig.collection_qig([[1, 2], [3, 4]], [])).to eq([1, 2, 3, 4])

        # but in qig, this conflicts conceptually with the simple array handling
        #
        # Should Qig.qig([[1, 2], [3, 4]], []) operate on the outermost array, or on the inner arrays?
        # - In jq, this would operate at the top-level:
        #   unwrap the top-level array and add its elements to the stream, producing [1, 2] [3, 4]
        # - This is consistent with jq's indexing behavior in the simple array case:


        #
        # We can emulate a stream by wrapping the results in an array:
        
        expect(Qig.qig [[1, 2], [3, 4]]).to eq([[1, 2], [3, 4]])

        # but isn't this just the input?
        #
        # Yes, but Qig's internal state has changed. Since the outer array is now the "stream", 

        expect(Qig.qig([[1, 2], [3, 4]], [], [])).to eq([1, 2, 3, 4])
      end

      # [] is conceptually simple: it unboxes collections and dumps their contents into jq's stream.
      # It's very simlar to a flatten, except jq will raise an exception if we try to unbox an atom.
      # TODO: look at how jq formally defines this and rewrite for consistency.
      #
      # In qig, [] _is exactly_ flatten: it unboxes top-level collections, and preserves atoms
      #
      # But, the prior tests show qig treating its input as a single atom rather than a stream.
      # If we're following jq semantics, then given an array shouldn't Qig try to unbox the top-level array?
      # That is to say...
      #
      # Qig.qig([[1, 2], [3, 4]], [])) => [1, 2], [3, 4] # what would this even mean? Are we suddenly writing perl?
      #
      # Qig solves this as follows:
      # - initial input is treated as a unit (or a stream of one), and it tries to return a unit
      # - if we try to _unbox_ the initial unit, Qig drops down a level, treating that top-level collection as the stream.

    end

    context 'when I [] something that is not an array'
      it 'preserves the item (like flatten)' do

      end

      xit 'throws an error (like jq)'
    end
  end
end
