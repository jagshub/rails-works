# frozen_string_literal: true

module Admin::MultiFactor
  extend self

  # Note(TC): We only execute the 2FA step if the user is an admin, we are in prod
  # and the provider they authenticated with is not already Google
  def authenticate?(user, provider)
    user.admin? && Rails.env.production? && !SignIn::AuthResponse::Google::ALL_PROVIDERS.include?(provider) && user.email.present?
  end

  def create_and_deliver!(user)
    multi_factor_token = user.multi_factor_tokens.create!
    AdminMailer.multi_factor_authentication(multi_factor_token).deliver_now
  end
end
