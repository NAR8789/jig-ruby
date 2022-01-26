# frozen_string_literal: true

require_relative 'qig/version'

# Combining the powers of `dig` and `jq`.
# Qig is dig extended with jq's value iteration `[]` operator.
module Qig
  autoload :Qiggable, 'qig/qiggable.rb'

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

    def unit_qig(subject, *path) # rubocop:disable Metrics/MethodLength
      head, *rest = path
      case head
      in nil
        subject
      in []
        collection_qig(values(subject), *rest)
      in [[]]
        unit_qig([subject], *rest)
      in ['', key]
        unit_qig(step(subject, key), *rest)
      in [[method, [*args], block]]
        unit_qig(subject.public_send(method, *args, &block), *rest)
      in [[method, [*args]]]
        unit_qig(subject.public_send(method, *args), *rest)
      in [[method]]
        unit_qig(subject.public_send(method), *rest)
      in [method, *]
        raise ArgumentError, 'stream method invocation not applicable in unit context'
      else
        unit_qig(step(subject, head), *rest)
      end
    end

    def collection_qig(subjects, *path) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      head, *rest = path
      case head
      in nil
        subjects
      in []
        collection_qig(subjects.map(&method(:values)).flatten(1), *rest)
      in [[]]
        unit_qig(subjects, *rest)
      in ['', key]
        collection_qig(subjects.map { |s| step(s, key) }, *rest)
      in [[method, [*args], block]]
        collection_qig(subjects.map { |s| s.public_send(method, *args, &block) }, *rest)
      in [[method, [*args]]]
        collection_qig(subjects.map { |s| s.public_send(method, *args) }, *rest)
      in [[method]]
        collection_qig(subjects.map { |s| s.public_send(method) }, *rest)
      in [method, [*args], block]
        collection_qig(subjects.public_send(method, *args, &block), *rest)
      in [method, [*args]]
        collection_qig(subjects.public_send(method, *args), *rest)
      in [method]
        collection_qig(subjects.public_send(method), *rest)
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
