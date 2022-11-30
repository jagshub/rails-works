# frozen_string_literal: true

class TeamMailer < ApplicationMailer
  helper MailHelper
  helper TeamHelper

  ## Requests

  def request_sent(request)
    email_campaign_name 'team_request_sent'

    email = request.team_email || request.user.email
    return if email.blank?

    @is_first_claim = request.product.team_members.owner.empty?
    @product = request.product
    @user = request.user
    @verify_email = @is_first_claim && request.team_email.present? && !request.team_email_confirmed?
    @confirm_url = Routes.team_request_url(token: request.verification_token)

    subject = @is_first_claim ? 'Hub owner - Request sent' : "Your request to manage #{ @product.name } has been sent"

    mail to: email, subject: subject
  end

  def request_received(request, member)
    email_campaign_name 'team_request_received'

    receiver = member.user
    email = receiver.email

    return if email.blank?

    @product = request.product
    @user = request.user

    mail to: email, subject: "#{ @user.name } is requesting access to #{ @product.name }"
  end

  def request_approved(request)
    email_campaign_name 'team_request_approved'

    email = request.user.email
    return if email.blank?

    @is_owner = request.team_member.owner?
    @product = request.product

    subject = @is_owner ? "You’re now an owner of #{ @product.name }" : "You have joined #{ @product.name }"

    mail to: email, subject: subject
  end

  def request_rejected(request)
    email_campaign_name 'team_request_approved'

    email = request.user.email
    return if email.blank?

    @product = request.product
    @is_first_claim = @product.team_members.owner.empty?

    mail to: email, subject: "Your request to join #{ @product.name } has been declined"
  end

  ## Invites

  def invite_received(invite)
    email_campaign_name 'team_invite_received'

    email = invite.user.email
    return if email.blank?

    @product = invite.product
    @referrer = invite.referrer
    @invite_url = Routes.team_invite_url(invite)

    mail to: email, subject: "#{ @referrer.name } has invited you to join #{ @product.name }"
  end

  def invite_accepted(invite)
    email_campaign_name 'team_invite_accepted'

    email = invite.referrer.email
    return if email.blank?

    @product = invite.product
    @user = invite.user

    mail to: email, subject: "#{ @user.name } has joined #{ @product.name }"
  end

  def invite_rejected(invite)
    email_campaign_name 'team_invite_rejected'

    email = invite.referrer.email
    return if email.blank?

    @product = invite.product
    @user = invite.user

    mail to: email, subject: "#{ @user.name } has rejected your invite to join #{ @product.name }"
  end
end
