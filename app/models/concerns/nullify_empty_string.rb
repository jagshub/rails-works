# frozen_string_literal: true

# NOTE(Rahul): Used to nullify string/text column value when empty.
#
# Usage: extension NullifyEmptyString, columns: %i(note)

module NullifyEmptyString
  def self.define(model, columns: [])
    columns = Array(columns)

    model.before_validation do
      columns.each do |column|
        self[column] = self[column]&.strip.presence
      end
    end
  end
end
