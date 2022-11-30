# frozen_string_literal: true

class Search::Query::Utils::Options
  attr_reader :clauses

  def initialize(options_map, options_hash)
    @clauses = options_map.map do |option_key, process|
      option_value = options_hash[option_key]
      process.call(option_value) unless option_value.nil?
    end.compact
  end

  def merge_options(opts)
    return if clauses.blank?

    opts[:where] ||= {}
    opts[:where][:_and] ||= []
    opts[:where][:_and].concat(clauses)
  end
end
