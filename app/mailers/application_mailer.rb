# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper
  helper S3Helper
  helper UsersHelper
  helper MailHelper

  include Routes::CustomControllerPaths

  layout 'mailer'

  default from: CommunityContact.from(name: CommunityContact::PH_NAME, email: CommunityContact::PH_EMAIL)

  def initialize(*args)
    @delivery_method_options = {}

    super(*args)
  end

  def mail(params = {}, &block)
    params[:delivery_method_options] ||= {}
    params[:delivery_method_options].merge!(@delivery_method_options)

    super(params, &block)
  end

  # Note(rstankov): Allows us to group transactional emails into "Campaigns". Useful for analytics.
  #   Make it easily searchable.
  #   Don't include user or other record ids in the campaigns.
  #   Except for cases when you want special deduplication rules.
  #
  #   `deduplicate` - guards that same email from receiving the same campaign twice
  #
  #   Examples:
  #     email_campaign_name 'jobs_cancellation'
  #     email_campaign_name 'jobs_confirmation'
  #     email_campaign_name 'jobs_renewal'
  #     email_campaign_name 'founder_club_invite_code'
  #     email_campaign_name newsletter.email_campaign_name, deduplicate: true
  #
  #   X-Feedback-ID is for Gmail Postmaster tools
  #   https://support.google.com/mail/answer/6254652
  #
  #   Mj-campaign is for grouping in Mailjets analytics panel
  #   This header works for V3.0 of their API. Other versions have
  #   different headers, be careful!
  #   https://www.mailjet.com/docs/emails_headers
  #
  def email_campaign_name(campaign_name, deduplicate: false)
    formatted_name = format('%s:producthunt', campaign_name)

    raise "Too long campaign name - #{ formatted_name } (max 255)" if formatted_name.size > 255

    headers['X-Feedback-ID'] = formatted_name

    if deduplicate
      headers['X-Mailjet-DeduplicateCampaign'] = 1
      @delivery_method_options[:'mj-deduplicatecampaign'] = 1
    end

    # NOTE (k1): Headers are duplicated here so consumers can access them on mailer message instances
    headers['Mj-campaign'] = formatted_name
    @delivery_method_options[:'mj-campaign'] = formatted_name
  end

  # NOTE(rstankov): Mailjet attaches this id to the webhook event we receive
  #  More info - https://dev.mailjet.com/smtp-relay/custom-headers/
  def email_custom_id(*ids)
    headers['X-MJ-CustomID'] = ids.join('-')
    @delivery_method_options[:'mj-customid'] = ids.join('-')
  end

  # NOTE(rstankov): Mailjet attaches this data to the webhook event we receive
  #  More info - https://dev.mailjet.com/smtp-relay/custom-headers/
  def email_event_payload(payload)
    headers['X-MJ-EventPayload'] = payload.to_json
    @delivery_method_options[:'mj-eventpayload'] = payload.to_json
  end

  def disable_email_tracking
    # Note (Mike Coutermarsh): Use this to disable tracking for emails
    #   Useful if sending an email from a "person". Aka "From Kate"
    #   email looks more authentic + less likely to end up in Promo folder.

    headers['X-Mailjet-TrackOpen'] = 0
    headers['X-Mailjet-TrackClick'] = 0
    @delivery_method_options[:'mj-trackopen'] = 0
    @delivery_method_options[:'mj-trackclick'] = 0
  end
end
