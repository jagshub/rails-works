# frozen_string_literal: true

module Spam::User::PotentialSpammer
  extend self

  def call(auth_response)
    account_has_default_profile_image?(auth_response) || account_too_young(auth_response) || account_without_name(auth_response)
  end

  private

  def account_has_default_profile_image?(auth_response)
    auth_response.default_profile_image?
  end

  def account_too_young(auth_response)
    auth_response.created_at.present? && auth_response.created_at > 5.days.ago
  end

  def account_without_name(auth_response)
    auth_response.user_params[:name].blank?
  end
end
