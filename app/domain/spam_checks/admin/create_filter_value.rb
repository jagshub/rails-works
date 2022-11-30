# frozen_string_literal: true

require 'csv'

module SpamChecks::Admin::CreateFilterValue
  extend self

  def call(inputs)
    if inputs[:csv_file].present?
      create_values_from_csv inputs
    else
      Spam::FilterValue.create! inputs
    end
  end

  private

  def create_values_from_csv(inputs)
    ActiveRecord::Base.transaction do
      CSV.parse(inputs[:csv_file].read, headers: false).each do |row|
        record = ::Spam::FilterValue.find_or_initialize_by(filter_kind: row[0], value: row[1].strip)

        record.update! added_by_id: inputs[:added_by_id], note: row[2] if record.new_record?
      end
    end
  end
end
