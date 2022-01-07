# frozen_string_literal: true

RSpec.describe Qig do
  it 'has a version number' do
    expect(Qig::VERSION).not_to be nil
  end

  describe '#qig', :aggregate_failures do
    it 'handles trivial caess' do
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
    end

    it 'treats the first level of [] as array descent' do
      expect(Qig.qig([[1, 2], [3, 4]], [])).to eq([[1, 2], [3, 4]])
      expect(Qig.qig([[1, 2], [3, 4]], [], 0)).to eq([1, 3])
      expect(Qig.qig([[1, 2], [3, 4]], [], 1)).to eq([2, 4])
      expect(Qig.qig([[1, 2], [3, 4]], [], 2)).to eq([nil, nil])
      expect(Qig.qig([[1, 2], [3, 4]], [], 2, 0)).to eq([nil, nil])
    end

    it 'treats the second level of [] as flattening' do
      expect(Qig.qig([[1, 2], [3, 4]], [], [])).to eq([1, 2, 3, 4])
    end
  end
end
