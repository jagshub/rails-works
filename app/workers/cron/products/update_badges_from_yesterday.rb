# frozen_string_literal: true

class Cron::Products::UpdateBadgesFromYesterday < ApplicationJob
  def perform
    yesterday = 1.day.ago.to_date

    Badges::TopPostBadge.with_data(period: 'daily', date: yesterday).find_each do |badge|
      product = badge.subject.new_product
      Products::RefreshActivityEvents.new(product) if product
    end
  end
end
