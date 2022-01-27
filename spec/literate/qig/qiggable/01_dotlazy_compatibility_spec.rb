# frozen_string_literal: true

RSpec.describe Qig::Qiggable, :aggregate_failures do
  describe '.lazy compatibility' do
    let(:a) { Class.new(Array).include Qig::Qiggable }
    let(:r) { Class.new(Range).include Qig::Qiggable }

    it 'can call .qig after .lazy' do
      expect { a[1, 2, 3].lazy.qig }.not_to raise_error
      expect(a[1, 2, 3].lazy.qig.to_a).to eq([1, 2, 3])
      expect(r.new('a', nil).lazy.qig(10..12).to_a).to eq(%w[k l m])
    end
  end
end
