# frozen_string_literal: true

module EmailValidator
  extend self

  def valid?(email)
    return false if email.blank?

    # Note: Validates email returns a message in case `email` is not an email
    ValidatesEmailFormatOf.validate_email_format(email).nil?
  end

  def normalize(email)
    return if email.blank?

    FatFingers.clean_up_typoed_email(email.downcase)&.downcase
  end
end
