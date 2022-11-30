# frozen_string_literal: true

class CssHexColorValidator < ActiveModel::EachValidator
  CSS_HEX_VALIDATOR = /\A#(?:[0-9a-f]{3})(?:[0-9a-f]{3})?\z/i.freeze

  def validate_each(object, attribute, value)
    return if value =~ CSS_HEX_VALIDATOR

    object.errors[attribute] << (options[:message] || 'must be a valid CSS hex color code')
  end
end
