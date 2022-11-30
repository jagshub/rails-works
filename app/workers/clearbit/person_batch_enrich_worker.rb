# frozen_string_literal: true

class Clearbit::PersonBatchEnrichWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  queue_as :long_running

  REFRESH_PERIOD = 6.months.freeze

  def perform
    enrich_count = 0
    get_enrich_users.find_in_batches(batch_size: 500) do |users|
      # NOTE(DZ): Clearbit limit 600 requests per minute, throttle by 60 seconds
      # on every 500 batches
      sleep(60)
      users.each do |user|
        profile = get_clearbit_profile(user)

        # NOTE(DZ): For now we just look at the last time we updated the profile.
        # We also presist the `indexed_at` field, which is when Clearbit indexed
        # the profile. The main issue is their documentation is a bit opaque on
        # how they use this flag internally.
        next unless profile.nil? || profile.updated_at <= REFRESH_PERIOD.ago

        enrich_count += 1

        ClearbitProfiles.enrich_from_email(
          user.email,
          refresh: true,
          stream: false,
        )
      rescue StandardError => e
        Rails.logger.info(
          "#{ self.class } - User #{ user.id } #{ user.email } \
          error #{ e.message }",
        )
      end
    end

    Rails.logger.info("#{ self.class } - Enriched #{ enrich_count } users")
  end

  private

  def get_enrich_users
    total_count = ClearbitProfiles::EnrichQueue.length
    Rails.logger.info("#{ self.class } - #{ total_count } flushed")
    user_ids = ClearbitProfiles::EnrichQueue.reserve(limit: total_count)

    users =
      User
      .includes(:subscriber)
      .where(id: user_ids)
      .where.not(subscriber: { email: nil })

    preload_clearbit_profiles(users)

    users
  end

  def get_clearbit_profile(user)
    @profiles.find { |p| p.email == user.email }
  end

  def preload_clearbit_profiles(users)
    @profiles ||= Clearbit::PersonProfile.where(email: users.map(&:email))
  end
end
