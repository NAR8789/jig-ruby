# frozen_string_literal: true

RSpec.describe Qig, :aggregate_failures do
  describe 'reboxing' do
    it 'lets me hop from collection context back up to unit context' do
      expect(Qig.qig([{ foo: 1 }, { foo: 2 }], [], :foo, [[]], 0)).to eq(1)
      expect(Qig.qig({ a: { b: [{ c: 1 }, { c: 2 }] } }, :a, :b, [], :c, [[]], 1)).to eq(2)
    end

    it "wraps additional arrays if I'm already in unit context" do
      expect(Qig.qig({ foo: :bar }, [[]])).to eq([{ foo: :bar }])
      expect(Qig.qig({ foo: :bar }, [[]], [[]])).to eq([[{ foo: :bar }]])
    end
  end
end
