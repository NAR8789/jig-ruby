# frozen_string_literal: true

RSpec.describe Qig::Qiggable, :aggregate_failures do
  let(:h) { Class.new(Hash) { include Qig::Qiggable } }

  it 'makes hash qiggable via chaining syntax' do
    expect(h[a: 1, b: [{ c: 1 }, { c: 2 }]].qig(:b, [], :c)).to eq([1, 2])
  end

  # I suspect this is much nicer to use than the method invocation syntax (TODO: examples)
end
