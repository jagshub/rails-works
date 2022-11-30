# frozen_string_literal: true

class Redshift::Base < ApplicationRecord
  self.abstract_class = true

  conf = Rails.application.secrets.redshift_config
  establish_connection conf if conf.present?

  def readonly?
    true
  end
end
