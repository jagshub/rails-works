# frozen_string_literal: true

class WebHooks::ViralloopsSweepSignupWorker
  include Sidekiq::Worker

  CAMPAIGNS = ['ebook_bestlaunches'].freeze

  def perform(payload = {})
    return unless CAMPAIGNS.include? payload['campaign']
    return if payload['events'].nil?
    return unless payload['events']['user'].present? || payload['events']['user']['email'].present?

    campaign_name = get_campaign_name payload['campaign']

    payload = [{ 'EMAIL' => payload['events']['user']['email'].downcase, 'CAMPAIGN_NAME' => campaign_name }]
    WebHooks::NewsletterPromotionSignupWorker.perform_async(payload)
  end

  private

  def get_campaign_name(campaign)
    return 'PH_BESTLAUNCHES_BOOK' if campaign == 'ebook_bestlaunches'

    ''
  end
end
