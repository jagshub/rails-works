# frozen_string_literal: true

module Graph::Mutations
  class AvatarSync < BaseMutation
    argument :medium, String, required: true

    returns String

    def perform(medium:)
      return if current_user.blank?

      profile_image_url(medium)
    rescue SignIn::TokenExpirationError => e
      error :base, "#{ e }. Please re-login with #{ medium } & try again!"
    rescue StandardError => e
      ErrorReporting.report_warning(e, extra: { user_id: current_user.id, medium: medium })
    end

    private

    def profile_image_url(medium)
      # Note (Mike Coutermarsh): Purpose of cache is cheap "Rate Limit" for syncing an avatar.
      Rails.cache.fetch("user_profile_image_lookup/#{ current_user.id }/#{ medium }", expires_in: 5.minutes) do
        return FacebookApi::ProfileImage::Sync.call(current_user) if medium == 'facebook'
        return TwitterApi::ProfileImage::Sync.call(current_user) if medium == 'twitter'
      end
    end
  end
end
