# frozen_string_literal: true

# NOTE(rstankov) Jobs are created from our webhooks app using the Sidekiq
# message format.
#
# The Sidekiq message format is different than the ActiveJob message format,
# and is way less complex. Make sure to include `Sidekiq::Worker` and not
# class `ActiveJob::Base`.
#
# In case we want to switch to the AJ message format we can look how Sidekiq
# does this internally: https://github.com/rails/rails/blob/master/activejob/lib/active_job/arguments.rb
#
# If you change the class make sure to change it in the webhooks app as well:
# https://github.com/producthunt/webhooks/blob/master/lib/constants.js
#
# Documentation https://dev.mailjet.com/email-api/v3/eventcallbackurl/
#               https://dev.mailjet.com/guides/#events

class WebHooks::ClearbitWorker
  include Sidekiq::Worker

  ACCEPTED_TYPES = %w(person_company).freeze

  def perform(payload = {})
    return unless payload['body']
    return unless payload['status'] == 200
    return unless ACCEPTED_TYPES.include? payload['type']

    HandleRaceCondition.call do
      ClearbitProfiles.enrich_from_webhook_payload(payload['body'])
    end
  end
end
