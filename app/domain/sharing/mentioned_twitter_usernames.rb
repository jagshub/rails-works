# frozen_string_literal: true

module Sharing
  class MentionedTwitterUsernames
    attr_reader :text

    class << self
      def call(text)
        new(text).call
      end
    end

    def initialize(text)
      @text = text
    end

    def call
      mentioned_users = []
      text.scan(%r{(^|[^/\w])(@\w{1,15})\b}).each do |match|
        _whitespace, mentioned_user = match

        user = User.find_by_username(mentioned_user.delete('@'))

        mentioned_users << if user.present? && user.twitter_username.present?
                             "@#{ user.twitter_username }"
                           else
                             mentioned_user
                           end
      end

      mentioned_users.uniq
    end
  end
end
