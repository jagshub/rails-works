# frozen_string_literal: true

# == Schema Information
#
# Table name: settings
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#

class Setting < ApplicationRecord
  after_save :reload_settings

  class << self
    def next_id
      # NOTE(rstankov): The `id` sequence is broken, so we have to manually increase
      pluck('max(id)').first.to_i + 1
    end

    def enabled?(name)
      Setting.find_by(name: name)&.value == 'true'
    end
  end

  def reload_settings
    Rails.configuration.settings.reload
  end
end
