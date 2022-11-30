# frozen_string_literal: true

module SignIn
  class SetFirstTimeUserAttributes
    attr_reader :user

    class << self
      def call(user, auth_response, via_application_id = nil)
        return unless user.first_time_user?

        new(user, auth_response, via_application_id).call
      end
    end

    def initialize(user, auth_response, via_application_id)
      @user = user
      @auth_response = auth_response
      @via_application_id = via_application_id
    end

    def call
      user.update! role: correct_role, via_application_id: @via_application_id

      Image::Uploads::AvatarWorker.perform_later(user.image, user)
    end

    private

    def correct_role
      if Spam::User.potential_spammer?(@auth_response)
        :potential_spammer
      else
        :user
      end
    end
  end
end
