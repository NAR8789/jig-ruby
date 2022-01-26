# frozen_string_literal: true

RSpec.describe Qig::Qiggable, :aggregate_failures do
  describe '.lazy compatibility' do
    let(:a) { Class.new(Array) { include Qig::Qiggable } }

    pending 'can call .qig after .lazy' do
      expect { a[1, 2, 3].lazy.qig }.not_to raise_error
      expect(a[1, 2, 3].lazy.qig).to eq([1, 2, 3])
    end
  end
end
