# frozen_string_literal: true

class Newsletter::SubscribeForm
  include MiniForm::Model

  attributes :email, :status, :source

  validates :email, email_format: true, presence: true
  validate :ensure_email_available

  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def email=(value)
    @email = EmailValidator.normalize(value)
  end

  def perform
    Newsletter::Subscriptions.set(user: user,
                                  email: email,
                                  status: status,
                                  tracking_options: { source: source })
  end

  private

  def ensure_email_available
    return if user.blank?

    errors.add(:email, 'already taken') unless Subscriber.email_available? email, for_user: user
  end
end
