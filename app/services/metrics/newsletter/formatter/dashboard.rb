# frozen_string_literal: true

require 'active_support/core_ext/numeric/conversions'

module Metrics::Newsletter::Formatter::Dashboard
  extend self

  DashboardStats = Struct.new(:send_start, :subject, :delivered, :clicks, :opens, :click_percentage, :open_percentage, :link)

  def call(data)
    Metrics::Newsletter::Formatter.call(data) do |campaign, newsletter|
      data = {
        send_start: Time.at(campaign.send_time_start).in_time_zone,
        subject: campaign.subject,
        delivered: number_to_delimited(campaign.delivered_count),
        clicks: number_to_delimited(campaign.clicked_count),
        opens: number_to_delimited(campaign.opened_count),
        open_percentage: number_to_percentage((campaign.opened_count.to_f / campaign.delivered_count) * 100, precision: 2),
        click_percentage: number_to_percentage((campaign.clicked_count.to_f / campaign.delivered_count) * 100, precision: 2),
        link: newsletter ? Routes.newsletter_path(newsletter) : '',
      }

      # Note (Josh) Struct arguments are presented in order
      # This converts the hash into an array in the order it expects
      DashboardStats.new(*data.values_at(*DashboardStats.members))
    end
  end

  def number_to_delimited(number)
    number.to_s(:delimited)
  end

  def number_to_percentage(number, precision: 2)
    number.to_s(:percentage, precision: precision)
  end
end
