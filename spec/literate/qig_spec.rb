# frozen_string_literal: true

RSpec.describe Qig, :aggregate_failures do
  # Qig combines the powers of dig and jq. Or, it's dig with a jq-like twist.
  # Qig is like dig, but with jq's `[]` operator.
  # That is to say...

  context 'it behaves like dig' do
    it 'handles simple hash cases' do
      expect(Qig.qig({ a: 1, b: 2 }, :a)).to eq(1)
      expect(Qig.qig({ a: 1, b: 2 }, :b)).to eq(2)
      expect(Qig.qig({ a: 1, b: 2 }, :c)).to eq(nil)
      expect(Qig.qig({ a: 1, b: 2 }, :c, :d)).to eq(nil)
    end

    it 'handles simple array cases' do
      expect(Qig.qig([1, 2], 0)).to eq(1)
      expect(Qig.qig([1, 2], 1)).to eq(2)
      expect(Qig.qig([1, 2], 2)).to eq(nil)
      expect(Qig.qig([1, 2], 2, 0)).to eq(nil)
      expect(Qig.qig([[1, 2], [3, 4]], 0)).to eq([1, 2])
    end
  end

  context 'it behaves like jq' do
    xit "doesn't handle the more general-programming aspects of the jq dsl. For that, use ruby idioms instead"

    it 'handles simple jq documentation examples' # TODO: rephrase this
    # example with top-level hash with embedded array

    # in particular then, qig handles []: the unboxing operator
    describe '[]' do
      it 'behaves like flatten, preserving stray atoms (jq raises an error in this case)'
      # we do this because it's more in the spirit of dig's tendency towards "safe" navigation

      it 'unboxes hashes into their values' do
        expect(Qig.qig({ a: 1, b: 2 }, [])).to eq [1, 2]
        expect(Qig.qig({ a: 1, b: 2 }, [], [])).to eq [1, 2]
        expect(Qig.qig([{ a: 1, b: 2 }], [], [])).to eq [1, 2]
        expect(Qig.qig([{ a: 1, b: 2 }], [], [], [])).to eq [1, 2]
      end

      # TODO: wordsmith the rest of the following specs

      it 'treats the first level of [] as array descent' do
        expect(Qig.qig([[1, 2], [3, 4]], [])).to eq([[1, 2], [3, 4]])
        expect(Qig.qig([[1, 2], [3, 4]], [], 0)).to eq([1, 3])
        expect(Qig.qig([[1, 2], [3, 4]], [], 1)).to eq([2, 4])
        expect(Qig.qig([[1, 2], [3, 4]], [], 2)).to eq([nil, nil])
        expect(Qig.qig([[1, 2], [3, 4]], [], 2, 0)).to eq([nil, nil])
      end

      it 'treats further levels of [] as value iteration' do
        expect(Qig.qig([1, [2], [3, [4]]], [], [])).to eq([1, 2, 3, [4]])
        expect(Qig.qig([1, [2], [3, [4]]], [], [], [])).to eq([1, 2, 3, 4])
      end

      it 'WIP experimental examples' do
        array_pyramid = [[[[], []], []], []]
        expect(Qig.qig(array_pyramid)).to                         eq([[[[], []], []], []])
        expect(Qig.qig(array_pyramid, [])).to                     eq([[[[], []], []], []])
        expect(Qig.qig(array_pyramid, [], [])).to                 eq( [[[], []], []])      # rubocop:disable Layout/SpaceInsideParens
        expect(Qig.qig(array_pyramid, [], [], [])).to             eq(  [[], []])           # rubocop:disable Layout/SpaceInsideParens
        expect(Qig.qig(array_pyramid, [], [], [], [])).to         eq(   [])                # rubocop:disable Layout/SpaceInsideParens
        expect(Qig.qig(array_pyramid, [], [], [], [], [])).to     eq(   [])                # rubocop:disable Layout/SpaceInsideParens
        expect(Qig.qig(array_pyramid, [], [], [], [], [], [])).to eq(   [])                # rubocop:disable Layout/SpaceInsideParens

        expect(Qig.qig(array_pyramid, 0)).to                 eq( [[[], []], []])           # rubocop:disable Layout/SpaceInsideParens
        expect(Qig.qig(array_pyramid, [], 0)).to             eq([[[], []],       nil])
        expect(Qig.qig(array_pyramid, [], [], 0)).to         eq([[],             nil])
        expect(Qig.qig(array_pyramid, [], [], [], 0)).to     eq([nil,            nil])
        expect(Qig.qig(array_pyramid, [], [], [], [], 0)).to eq([                   ])     # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets

        pyramid = [0, [1, [2, [3]]]]
        expect(Qig.qig(pyramid                )).to eq([0, [1, [2, [3]]]])      # rubocop:disable Layout/SpaceInsideParens
        expect(Qig.qig(pyramid, []            )).to eq([0, [1, [2, [3]]]])      # rubocop:disable Layout/SpaceInsideParens
        expect(Qig.qig(pyramid, [], []        )).to eq([0,  1, [2, [3]]] )      # rubocop:disable Layout/SpaceInsideParens
        expect(Qig.qig(pyramid, [], [], []    )).to eq([0,  1,  2, [3]]  )      # rubocop:disable Layout/SpaceInsideParens
        expect(Qig.qig(pyramid, [], [], [], [])).to eq([0,  1,  2,  3]   )      # rubocop:disable Layout/SpaceInsideParens
        expect(Qig.qig(pyramid, [], [], [], [])).to eq([0,  1,  2,  3]   )      # rubocop:disable Layout/SpaceInsideParens

        eight = [[[1, 2], [3, 4]], [[5, 6], [7, 8]]]
        expect(Qig.qig(eight, 0)).to          eq([[1, 2], [3, 4]])
        expect(Qig.qig(eight, [], 0)).to      eq([[1, 2], [5, 6]])
        expect(Qig.qig(eight, [], [], 0)).to  eq([1, 3, 5, 7])
        expect(Qig.qig(eight, [], [], [])).to eq([1, 2, 3, 4, 5, 6, 7, 8])
      end
    end
  end

  context 'miscellaneous extensions to dig' do
    it 'handles trivial cases' do
      expect(Qig.qig({})).to eq({})
      expect(Qig.qig([])).to eq([])
      # more specifically, this is jq-like. dig gripes at you if you don't give it a path
    end

    it 'safely navigates top-level nil' do
      expect(Qig.qig(nil, 1, 2, 3)).to eq(nil)
      # dig safely navigates embedded nils but is not defined on nil for top-level nav
    end
  end
end
