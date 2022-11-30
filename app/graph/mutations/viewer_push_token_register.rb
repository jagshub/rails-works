# frozen_string_literal: true

module Graph::Mutations
  class ViewerPushTokenRegister < BaseMutation
    argument :browser_push_token, String, required: false

    def perform(browser_push_token: nil)
      register_token(browser_push_token)

      success
    end

    private

    def register_token(token)
      return if token.blank?

      Subscribers.register(
        user: current_user,
        browser_push_token: token,
      )
    rescue Subscribers::Register::DuplicatedSubscriberError
      nil
    end
  end
end
