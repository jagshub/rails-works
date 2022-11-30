# frozen_string_literal: true

module HasExpirationDate
  extend self

  def define(model, field_name: :expires_at, limit:)
    model.instance_eval do
      before_validation on: :create do
        public_send "#{ field_name }=", Time.zone.now + limit if public_send(field_name).blank?
      end

      scope :expired, -> { where('expires_at < NOW()') }
      scope :not_expired, -> { where('expires_at > NOW()') }

      validates field_name, presence: true

      define_method(:expired?) do
        public_send(field_name) < Time.zone.now
      end
    end
  end
end
