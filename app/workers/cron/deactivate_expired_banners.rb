# frozen_string_literal: true

module Cron
  class DeactivateExpiredBanners < ApplicationJob
    def perform
      Banner.active.where('end_date <  ?', Time.zone.today).find_each(&:inactive!)
    end
  end
end
