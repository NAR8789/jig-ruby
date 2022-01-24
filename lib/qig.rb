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
      when Array
        case head
        in [[method, *args], block]
          unit_qig(subject.public_send(method, *args, &block))
        in [method, *args]
          unit_qig(subject.public_send(method, *args), *rest)
        end
      else
        unit_qig(step(subject, head), *rest)
      end
    end

    def collection_qig(subjects, *path)
      head, *rest = path
      case head
      when nil
        subjects
      when []
        collection_qig(subjects.map(&method(:values)).flatten(1), *rest)
      when Array
        case head
        in [[method, *args], block]
          collection_qig(subjects.map { |s| s.public_send(method, *args, &block) }, *rest)
        in [method, *args]
          collection_qig(subjects.map { |s| s.public_send(method, *args) }, *rest)
        end
      else
        collection_qig(subjects.map { |s| step(s, head) }, *rest)
      end
    end

    def step(subject, key)
      subject&.[](key)
    rescue NameError, IndexError
      # Struct's [] is strict and raises on missing key.
      # TODO: more efficient / prettier way of doing this. How does struct itself implement dig?
      nil
    end
  end
end
