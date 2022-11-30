# frozen_string_literal: true

class HtmlTextLengthValidator < ActiveModel::EachValidator
  CLEAN_HTML_OPTIONS = { elements: [] }.freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    max_length = options[:maximum]

    raise "Provide :maximum option `html_text_length` validation of #{ attribute } in #{ record.class.name } " unless max_length

    text = Sanitize.fragment(value, CLEAN_HTML_OPTIONS).strip

    record.errors.add(attribute, "is too long. (maximum is #{ max_length } characters)") if text.length > max_length
  end
end
