# frozen_string_literal: true

RSpec.describe Qig, :aggregate_failures do
  describe 'method invocation' do
    describe 'subject method invocation' do
      it 'can invoke subject methods via an s-expression like syntax embedded in the qig path' do
        expect(Qig.qig([1, 2, nil, 3], [[:compact, []]])).to eq([1, 2, 3])
        expect(Qig.qig([[1, 2, nil, 3], [nil, 4, 5]], [], [[:compact, []]])).to eq([[1, 2, 3], [4, 5]])
      end

      it 'can omit trailing [] if no arguments passed' do
        expect(Qig.qig([1, 2, nil, 3], [[:compact]])).to eq([1, 2, 3])
        expect(Qig.qig([[1, 2, nil, 3], [nil, 4, 5]], [], [[:compact]])).to eq([[1, 2, 3], [4, 5]])
      end

      it 'can pass blocks, but the notation is ugly' do
        expect(Qig.qig([1, 2, 3], [[:filter, [], :even?]])).to eq([2])
        expect(Qig.qig([[1, 2, 3], [4, 5]], [], [[:filter, [], :even?]])).to eq([[2], [4]])
      end
    end

    describe 'top-level collection method invocation' do
      # invoking collection methods is useful but somewhat unweildy. Usually if we're invoking collection methods, we
      # probably want to be doing this at the top level, e.g. like jq's `select`

      it 'can select at top level' do
        expect(Qig.qig([1, 2, 3, 4, 5], [], [:select, [], :even?])).to eq([2, 4])
      end

      it 'stream-method-invocation is only meaningful in collection mode' do
        expect { Qig.qig([1, 2, 3, 4, 5], [:select, [], :even?]) }.to raise_error(ArgumentError)
      end
    end
  end
end
