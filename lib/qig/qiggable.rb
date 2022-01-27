# frozen_string_literal: true

module Qig
  # mix-in to add a `.qig` method to any class.
  # NOTE: Target class should support `#[]`, `#map`, and either `#flat_map` or `#values` for full qig functionality
  # - `#[]`: used for stepping in unit context
  # - `#map`: used for stepping in collection context
  # - `#flat_map` or `#values`: used for unboxing in collection context
  module Qiggable
    # @param path [Array<String, Symbol, Array, Object>] retrieval path to apply to `subject`
    #
    # @return [Object, Array<Object>] the value(s) of `self` located at `path`
    def qig(*path)
      Qig.qig(self, *path)
    end

    # see Enumerable#lazy
    #
    # This version extends the underlying lazy enumerable with Qig::Qiggable
    def lazy
      super.extend(Qig::Qiggable)
    end
  end
end
