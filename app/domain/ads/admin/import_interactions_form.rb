# frozen_string_literal: true

class Ads::Admin::ImportInteractionsForm
  include MiniForm::Model

  HEADERS = %w(
    channel_id
    kind
    track_code
    user_id
    ip_address
    user_agent
    reference
    created_at
  ).freeze

  attributes :csv

  def perform
    Ads::Backfill.from_csv(csv.path)
  end
end
