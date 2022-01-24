# frozen_string_literal: true

RSpec.describe Qig, :aggregate_failures do
  describe 'quoting' do
    it 'allows lookup on keys that have special meaning to qig' do
      expect(Qig.qig({ [] => :hello }, [])).to eq([:hello]) # but how to lookup by []?
      expect(Qig.qig({ [] => :hello }, [[:[], [[]]]])).to eq(:hello) # this works but is hideous
      expect(Qig.qig({ [] => :hello }, ['', []])).to eq(:hello) # preferred method; much more readable
      expect(Qig.qig([{ [] => :hello }, { [] => :world }], [], ['', []])).to eq(%i[hello world])
    end
  end
end
