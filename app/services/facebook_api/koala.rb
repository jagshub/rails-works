# frozen_string_literal: true

module FacebookApi::Koala
  extend self

  def call(token)
    Koala::Facebook::API.new(token, Config.secret(:facebook_app_secret))
  end
end
