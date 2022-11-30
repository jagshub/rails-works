# frozen_string_literal: true

module Teams::Requests::Create
  extend self

  def call(user:, product:, team_email: nil, additional_info: nil)
    return if member_exists?(product, user)
    return if duplicate_request?(product, user)
    return if accept_invite_for_same_user(product, user)

    ApplicationRecord.transaction do
      request = ::Team::Request.new(
        user: user,
        product: product,
        team_email: team_email,
        additional_info: additional_info,
      )
      request.team_email_confirmed = Teams.request_email_verified?(request: request)
      request.save!

      if Teams.request_auto_approve?(request: request)
        # Note(DT): We auto-approve only the first claim, all further requests are sent by the team owner
        Teams.request_approve(request: request, approval_type: :auto)
      else
        Teams.request_send_email_verification(request: request)
        send_request_received_email_to_team(request)
      end

      request
    end
  end

  private

  def member_exists?(product, user)
    Team::Member.exists?(product: product, user: user)
  end

  def accept_invite_for_same_user(product, user)
    # Note(DT): If the user already was invited to the product, not accepted it yet, and sent a new request instead,
    # we can accept the invite, because it has the same effect as approving the request.
    related_invite = Team::Invite.pending.find_by(product: product, user: user)
    return false unless related_invite

    Teams.invite_accept(invite: related_invite)
    true
  end

  def duplicate_request?(product, user)
    Team::Request.where(
      product: product,
      user: user,
    ).pending.exists?
  end

  def send_request_received_email_to_team(request)
    team_members = request.product.team_members.active

    team_members.find_each do |member|
      TeamMailer.request_received(request, member).deliver_later
    end
  end
end
