# frozen_string_literal: true

require_relative 'qig/version'

module Qig
  def self.qig(*args)
    unit_qig(*args)
  end

  def self.unit_qig(subject, *path)
    return subject if subject.nil?

    head, *rest = path
    case head
    when nil
      subject
    when []
      collection_qig(subject, *rest)
      # hmm... what should happen if I [] on something not an array?
    else
      unit_qig(subject[head], *rest)
    end
  end

  def self.collection_qig(subjects, *path)
    return subjects if subjects.empty?

    head, *rest = path
    case head
    when nil
      subjects
    when []
      collection_qig(subjects.flatten(1), *rest)
      # not sure this is quite jq-compliant... [] refuses to iterate over atoms, but flatten will just preserve them.
      # maybe more in the spirit of `dig` though?
    else
      collection_qig(subjects.map { |e| e.nil? ? e : e[head] }, *rest)
    end
  end
end
