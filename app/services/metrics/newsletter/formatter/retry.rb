# frozen_string_literal: true

module Metrics::Newsletter::Formatter::Retry
  extend self

  RetryStats = Struct.new(:product_hunt_id, :subject, :delivered)

  def call(data)
    Metrics::Newsletter::Formatter.call(data) do |campaign, newsletter|
      data = {
        product_hunt_id: newsletter ? newsletter.id : nil,
        subject: campaign.subject,
        delivered: campaign.delivered_count,
      }

      # Note (Josh) Struct arguments are presented in order
      # This converts the hash into an array in the order it expects
      RetryStats.new(*data.values_at(*RetryStats.members))
    end
  end
end
