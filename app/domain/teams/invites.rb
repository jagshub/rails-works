# frozen_string_literal: true

module Teams::Invites
  extend self

  class CreateError < StandardError
  end

  def create(product:, user:, referrer:)
    raise CreateError, 'This user is already a team member.' if Team::Member.where(user: user, product: product).exists?

    raise CreateError, 'This user has already submitted a request.' if Team::Request.where(user: user, product: product).pending.exists?

    old_invite = Team::Invite.find_by(user: user, product: product)
    raise CreateError, 'This user already has a pending invite.' if old_invite&.pending?

    old_invite&.destroy!

    invite = Team::Invite.create!(
      user: user,
      product: product,
      referrer: referrer,
      status: :pending,
      identity_type: :user,
    )

    TeamMailer.invite_received(invite).deliver_later

    invite
  end

  def accept(invite:)
    return false if invite.status != 'pending'
    return false if invite_expired_or_member_exists?(invite)

    ActiveRecord::Base.transaction do
      invite.update!(status: 'accepted')

      ::Team::Member.create!(
        user: invite.user,
        product: invite.product,
        referrer: invite,
        role: 'member',
      )
    end

    TeamMailer.invite_accepted(invite).deliver_later

    true
  end

  def reject(invite:)
    return false if invite.status != 'pending'
    return false if invite_expired_or_member_exists?(invite)

    invite.update!(status: 'rejected')

    TeamMailer.invite_rejected(invite).deliver_later

    true
  end

  private

  def invite_expired_or_member_exists?(invite)
    invite.expired? || Team::Member.exists?(user: invite.user, product: invite.product)
  end
end
