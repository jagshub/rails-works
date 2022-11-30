# frozen_string_literal: true

module Mobile::Graph::Utils
  class SignInToken
    attr_reader :access_token, :first_time_user

    def initialize(token, user)
      @access_token = token.token
      @first_time_user = user.first_time_user?
    end

    def type
      'bearer'
    end
  end
end
