# frozen_string_literal: true

# Often, validation of a model will depend on validation of its sub models.
# This can be used to validate any sub models. Useful for service or form objects.
#
# Example:
# validates :user, :notification_settings, nested: true

class NestedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.is_a?(Enumerable)
      value.each { |v| validate_each(record, attribute, v) }
    else
      return if value.valid?

      record.errors.merge!(value.errors)
    end
  end
end
