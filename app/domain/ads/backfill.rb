# frozen_string_literal: true

module Ads::Backfill
  extend self

  UNIQUE_KEYS = %w(channel_id track_code user_id kind).freeze

  def from_csv(csv_path)
    channels_to_update = []

    row_number = 0
    CSV.foreach(csv_path, headers: true, encoding: 'UTF-8') do |row|
      hash_row = row.to_h
      attributes = hash_row.slice!(*UNIQUE_KEYS)

      interaction = Ads::Interaction.find_or_initialize_by(hash_row)
      interaction.backfill_at = Time.current
      interaction.attributes = attributes
      interaction.save!

      channels_to_update << interaction.channel_id
      row_number += 1
    rescue StandardError => e
      ErrorReporting.report_error(e, extra: { row_number: row_number })
    end

    channels_to_update.uniq.each do |channel_id|
      channel = Ads::Channel.find channel_id
      Ads::Fill.refresh_fill(channel)
    end
  end
end
