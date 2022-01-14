# frozen_string_literal: true

require_relative 'qig/version'

module Qig
  def self.qig(*args)
    unit_qig(*args)
  end

  def self.unit_qig(subject, *path)
    head, *rest = path
    case head
    when nil
      subject
    when []
      subject = subject&.values if subject.is_a? Hash
      collection_qig(subject, *rest)
    else
      unit_qig(subject&.[](head), *rest)
    end
  end

  def self.collection_qig(subjects, *path)
    head, *rest = path
    case head
    when nil
      subjects
    when []
      collection_qig(subjects.map { |s| s.is_a?(Hash) ? s.values : s }.flatten(1), *rest)
      # not sure this is quite jq-compliant... [] refuses to iterate over atoms, but flatten will just preserve them.
      # maybe more in the spirit of `dig` though?
    else
      collection_qig(subjects.map { |e| e.nil? ? e : e[head] }, *rest)
    end
  end
end
