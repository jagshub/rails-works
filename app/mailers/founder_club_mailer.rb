# frozen_string_literal: true

class FounderClubMailer < ApplicationMailer
  def access_request_invite_code(access_request)
    email_campaign_name 'Founder Club Invite Code'

    @access_request = access_request

    mail(
      to: @access_request.email,
      subject: access_request.referral? ? 'You have been referred for Founder Club by Product Hunt' : 'Your Invite Code for Founder Club by Product Hunt',
      reply_to: CommunityContact::REPLY,
    )
  end

  def deal_redemption_codes_exhausted(deal)
    email_campaign_name 'Founder Club Deal Redemption Codes Exhausted'

    @deal = deal

    mail(
      to: [CommunityContact::FOUNDER_CLUB_CONTACT, CommunityContact::REPLY],
      subject: 'All your Redemption codes for Founder Club were used',
    )
  end
end
