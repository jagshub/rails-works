# frozen_string_literal: true

module API::V1::Errors
  class InvalidInput < StandardError
    attr_reader :messages

    def initialize(messages = {})
      @messages = messages
    end
  end
end
