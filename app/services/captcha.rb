# frozen_string_literal: true

class Captcha
  API_URL = 'https://www.google.com/recaptcha/api/siteverify'

  class << self
    def verify_user(user, response)
      return false if response.blank?
      return true unless user.potential_spammer?

      if verify(response)
        Users::UpdateRole.call(user: user, suggested_role: :user)
        true
      else
        false
      end
    end

    def verify(response)
      data = {
        secret: ENV['GOOGLE_RECAPTCHA_SECRET_KEY'],
        response: response,
      }

      RestClient.post API_URL, data
    end
  end
end
