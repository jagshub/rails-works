# frozen_string_literal: true

class Ships::Admin::TransferSubscription
  attr_reader :owner, :receiver

  class << self
    def call(owner, receiver_username)
      new(owner, receiver_username).call
    end
  end

  def initialize(owner, receiver_username)
    @owner = owner
    @receiver = User.find_by_username(receiver_username)
  end

  def call
    return :invalid_username if receiver.nil?
    return :already_ship_pro if active_subscription?(receiver)
    return :receiver_have_active_account if content?(receiver)

    ShipSubscription.transaction do
      remove_receiver_ship_subscription_and_related
      transfer_owner_ship_subscription_and_related_to_receiver
    end

    :success
  rescue StandardError => e
    ErrorReporting.report_error e

    :internal_error
  end

  private

  def content?(receiver)
    receiver.ship_account&.content?
  end

  def active_subscription?(receiver)
    subscription = Ships::Subscription.new(receiver)
    subscription.premium? && !subscription.in_trial?
  end

  def remove_receiver_ship_subscription_and_related
    receiver.ship_subscription&.destroy!
    receiver.ship_billing_information&.destroy!
    receiver.ship_user_metadata&.destroy!
    receiver.ship_account&.destroy!
  end

  def transfer_owner_ship_subscription_and_related_to_receiver
    owner.ship_account&.update!(user: receiver)
    owner.ship_subscription&.update!(user: receiver)
    owner.ship_billing_information&.update!(user: receiver)
    owner.ship_user_metadata&.update!(user: receiver)

    UpcomingPage.where(user: owner).update_all(user_id: receiver.id)
  end
end
