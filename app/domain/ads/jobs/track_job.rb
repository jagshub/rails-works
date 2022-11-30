# frozen_string_literal: true

class Ads::Jobs::TrackJob < ApplicationJob
  include ActiveJobHandleDeserializationError
  include ActiveJobHandlePostgresErrors

  queue_as :tracking

  def perform(**args)
    args[:track_code] = Utf8Sanitize.call(args[:track_code])
    args[:user_agent] = Utf8Sanitize.call(args[:user_agent])
    args[:reference] = Utf8Sanitize.call(args[:reference])

    interaction = Ads::Interaction.create!(args)

    Ads.fill_interaction interaction: interaction
  end
end
