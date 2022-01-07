# frozen_string_literal: true

require_relative 'qig/version'

module Qig
  def self.qig(*args)
    qig_apply(*args)
  end

  def self.qig_apply(unit, *path)
    return unit if unit.nil?

    head, *rest = path
    case head
    when nil
      unit
    when []
      qig_map(unit, *rest)
      # hmm... what should happen if I [] on something not an array?
    else
      qig_apply(unit[head], *rest)
    end
  end

  def self.qig_map(collection, *path)
    return collection if collection.empty?

    head, *rest = path
    case head
    when nil
      collection
    when []
      qig_map(collection.flatten(1), *rest)
      # not sure this is quite jq-compliant... [] refuses to iterate over atoms, but flatten will just preserve them.
      # maybe more in the spirit of `dig` though?
    else
      qig_map(collection.map { |e| e.nil? ? e : e[head] }, *rest)
    end
  end
end
