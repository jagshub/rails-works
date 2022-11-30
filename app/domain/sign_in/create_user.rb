# frozen_string_literal: true

module SignIn
  module CreateUser
    extend self

    MAX_RETRIES = 100
    FALLBACK_NAME = 'New User'
    FALLBACK_USERNAME = 'new_user__%07d%s'

    def call(auth_response)
      username = auth_response.suggested_username

      if username.present?
        (0..MAX_RETRIES).each do
          unless SignIn::ValidUsername.call(username, auth_response: auth_response)
            username = username[/[0-9]+$/] ? username.gsub(/[0-9]+$/, &:succ) : username + '1'
            next
          end

          user = create_user(auth_response, username)
          return user if user.present?
        end
      end

      yday = Time.zone.today.yday.to_s
      year = Time.zone.today.year.to_s
      (0..MAX_RETRIES).each do
        username = format(FALLBACK_USERNAME, yday + year, SecureRandom.hex(8))

        user = create_user(auth_response, username)
        return user if user.present?
      end

      raise StandardError, format("Can't find a valid username, last try was %s", username)
    end

    private

    def create_user(auth_response, username)
      params = auth_response.user_params.merge(username: username)
      params[:name] = (params[:name].presence || FALLBACK_NAME)[0..User::MAX_LENGTH_NAME - 1]

      ErrorReporting.set_user(**params)

      email = params.delete(:email)
      email = nil if !EmailValidator.valid?(email) || !Subscriber.email_available?(email)

      params.delete(:website_url) unless ValidateWebsiteUrl.valid?(params[:website_url])

      user = User.create! params

      Subscribers.register user: user, email: email

      Iterable::SyncUserWorker.perform_later(user: user)

      Iterable.trigger_event('new_user', email: email, user_id: user.id) if email.present?

      user
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
      nil # Note(LukasFittl): Unlikely race condition where someone else signed up with the same username
    end
  end

  class ValidateWebsiteUrl
    include ActiveModel::Validations

    attr_accessor :website_url

    validates :website_url, url: { allow_nil: true, allow_blank: true }

    def self.valid?(website_url)
      model = new
      model.website_url = website_url
      model.valid?
    end
  end
end
