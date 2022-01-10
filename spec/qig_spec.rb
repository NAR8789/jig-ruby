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
      expect(Qig.qig([[1, 2], [3, 4]], 0)).to eq([1, 2])

      # this last example is interesting... what if we want to grab the 0th element of each subarray instead?
      # For that, we turn to []
    end

    describe '[]' do
      it 'treats the first level of [] as array descent' do
        expect(Qig.qig([[1, 2], [3, 4]], [])).to eq([[1, 2], [3, 4]])
        expect(Qig.qig([[1, 2], [3, 4]], [], 0)).to eq([1, 3])
        expect(Qig.qig([[1, 2], [3, 4]], [], 1)).to eq([2, 4])
        expect(Qig.qig([[1, 2], [3, 4]], [], 2)).to eq([nil, nil])
        expect(Qig.qig([[1, 2], [3, 4]], [], 2, 0)).to eq([nil, nil])
      end

      it 'treats further levels of [] as unboxing' do
        expect(Qig.qig([1, [2], [3, [4]]], [], [])).to eq([1, 2, 3, [4]])
        expect(Qig.qig([1, [2], [3, [4]]], [], [], [])).to eq([1, 2, 3, 4])
      end

      # Why the difference here between the first and second appliations of []?
      #
      # Conceptually, let's think of [] as always performing unboxing.
      # The difference in the first case is Qig needs a way to _return_ the unboxed results.
      #
      # That is to say, if the first level were just unboxing, we'd get...
      #
      #     expect(Qig.qig([1,2,3])).to eq 1,2,3
      #
      # Which is nonsensical, because this isn't perl. To return multiple values we need a container.
      # Qig needs to _rebox_ the results to return them.
      #
      # ergo...

      it 'treats the first level of [] as unboxing then reboxing' do
        expect(Qig.qig([1, 2, 3], [])).to eq([1,2,3])
      end

      # Which looks like a no-op, but for later steps Qig will be operating one level down

      it 'is meaningfully different from a no-op' do
        # these look the same on the surface...

        expect(Qig.qig([[1, 2], [3, 4]])).to eq([[1, 2], [3, 4]])
        expect(Qig.qig([[1, 2], [3, 4]], [])).to eq([[1, 2], [3, 4]])

        # but the difference is apparent one step further in

        expect(Qig.qig([[1, 2], [3, 4]], 0)).to eq([1, 2])
        expect(Qig.qig([[1, 2], [3, 4]], [], 0)).to eq([1, 3])
      end

      # More abstractly, this comes down to bridging a fundamental divide between `dig` and `jq`

      it 'experimental examples' do
        array_pyramid = [[[[], []], []], []]
        expect(Qig.qig(array_pyramid)).to                         eq([[[[], []], []], []])
        expect(Qig.qig(array_pyramid, [])).to                     eq([[[[], []], []], []])
        expect(Qig.qig(array_pyramid, [], [])).to                 eq( [[[], []], []])
        expect(Qig.qig(array_pyramid, [], [], [])).to             eq(  [[], []])
        expect(Qig.qig(array_pyramid, [], [], [], [])).to         eq(   [])
        expect(Qig.qig(array_pyramid, [], [], [], [], [])).to     eq(   [])
        expect(Qig.qig(array_pyramid, [], [], [], [], [], [])).to eq(   [])

        expect(Qig.qig(array_pyramid, 0)).to                 eq( [[[], []], []])
        expect(Qig.qig(array_pyramid, [], 0)).to             eq([[[], []],       nil])
        expect(Qig.qig(array_pyramid, [], [], 0)).to         eq([[],             nil])
        expect(Qig.qig(array_pyramid, [], [], [], 0)).to     eq([nil,            nil])
        expect(Qig.qig(array_pyramid, [], [], [], [], 0)).to eq([                   ])

        pyramid = [0, [1, [2, [3]]]]
        expect(Qig.qig(pyramid                )).to eq([0, [1, [2, [3]]]])
        expect(Qig.qig(pyramid, []            )).to eq([0, [1, [2, [3]]]])
        expect(Qig.qig(pyramid, [], []        )).to eq([0,  1, [2, [3]]] )
        expect(Qig.qig(pyramid, [], [], []    )).to eq([0,  1,  2, [3]]  )
        expect(Qig.qig(pyramid, [], [], [], [])).to eq([0,  1,  2,  3]   )
        expect(Qig.qig(pyramid, [], [], [], [])).to eq([0,  1,  2,  3]   )

        eight = [[[1, 2], [3, 4]], [[5, 6], [7, 8]]]
        expect(Qig.qig(eight, 0)).to          eq([[1, 2], [3, 4]])
        expect(Qig.qig(eight, [], 0)).to      eq([[1, 2], [5, 6]])
        expect(Qig.qig(eight, [], [], 0)).to  eq([1, 3, 5, 7])
        expect(Qig.qig(eight, [], [], [])).to eq([1, 2, 3, 4, 5, 6, 7, 8])
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
  end
end
