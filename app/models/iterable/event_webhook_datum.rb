# frozen_string_literal: true

# == Schema Information
#
# Table name: iterable_event_webhook_data
#
#  id            :bigint(8)        not null, primary key
#  event_name    :string           not null
#  email         :string
#  workflow_name :string
#  campaign_name :string
#  data_fields   :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_iterable_event_webhook_data_on_email       (email)
#  index_iterable_event_webhook_data_on_event_name  (event_name)
#

# Model to save iterable's webhook event data

class Iterable::EventWebhookDatum < ApplicationRecord
  self.table_name = 'iterable_event_webhook_data'
end
