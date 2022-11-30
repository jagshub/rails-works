# frozen_string_literal: true

module FounderClub::Admin::TransferSubscription
  extend self

  def call(owner, receiver_username)
    receiver = User.find_by_username(receiver_username)

    return :invalid_username if receiver.nil?
    return :active_founder_club_subscription if active_subscription?(receiver)

    transfer_founder_club_subscription(owner, receiver)

    :success
  rescue StandardError => e
    ErrorReporting.report_error e

    :internal_error
  end

  private

  def active_subscription?(receiver)
    receiver.payment_subscriptions.find_by(project: 1).present?
  end

  def transfer_founder_club_subscription(owner, receiver)
    subscription = owner.payment_subscriptions.find_by(project: 1)

    Payment::Subscription.transaction do
      subscription.update!(user: receiver)
      owner.founder_club_claims.each { |claim| receiver.founder_club_claims.create!(claim.dup.attributes) }
      owner.founder_club_claims.destroy_all
    end
  end
end
