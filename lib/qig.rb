# frozen_string_literal: true

require_relative 'qig/version'

# Combining the powers of `dig` and `jq`.
# Qig is dig extended with jq's value iteration `[]` operator.
module Qig
  class << self
    # @param subject [Array, Hash, #[]] `subject` to be qug into.
    # @param path [Array<String, Symbol, Array, Object>] retrieval path to apply to `subject`
    #
    # @return [Object, Array<Object>] the value(s) of `subject` located at `path`
    def qig(subject, *path)
      unit_qig(subject, *path)
    end

    # "values" as in jq's "value iterator".
    #
    # Coerce to array by taking the .values. Intuitively, get all possible values of `arrayish[x]`.
    #
    # @param arrayish [Array, Hash, #values, Object] array or hash or other to coerce to values
    # @return [Array, Array, Array, Object] array of coerced values
    def values(arrayish)
      arrayish.respond_to?(:values) ? arrayish.values : arrayish
    end

    private

    def unit_qig(subject, *path)
      head, *rest = path
      case head
      when nil
        subject
      when []
        collection_qig(values(subject), *rest)
      else
        unit_qig(subject&.[](head), *rest)
      end
    end

    def collection_qig(subjects, *path)
      head, *rest = path
      case head
      when nil
        subjects
      when []
        collection_qig(subjects.map(&method(:values)).flatten(1), *rest)
        # not sure this is quite jq-compliant... [] refuses to iterate over atoms, but flatten will just preserve them.
        # maybe more in the spirit of `dig` though?
      else
        collection_qig(subjects.map { |e| e&.[](head) }, *rest)
      end
    end
  end
end
