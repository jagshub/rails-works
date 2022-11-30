# frozen_string_literal: true

require 'csv'

module InputSuggestions::CreateFromCsv
  extend self

  def call(file)
    CSV.parse(file.read, headers: false).each do |row|
      InputSuggestion.find_or_create_by! name: row[0], kind: row[1], parent_id: row[2]
    end
  end
end
