# frozen_string_literal: true

module HasEmailField
  extend self

  def define(model, field_name: :email, uniqueness: true, allow_nil: false)
    model.class_eval do
      cattr_accessor :has_email_field

      self.has_email_field = field_name
    end

    model.instance_eval do
      include ::HasEmailField::Methods

      before_validation :normalize_email

      validates field_name, presence: true, email_format: true, uniqueness: uniqueness, allow_nil: allow_nil

      scope :with_email, ->(email) { where(field_name => EmailValidator.normalize(email)) }
    end
  end

  module Methods
    private

    def normalize_email
      email_address = self[self.class.has_email_field]
      normalized_email = EmailValidator.normalize(email_address)

      assign_attributes(self.class.has_email_field => normalized_email)
    end
  end
end
