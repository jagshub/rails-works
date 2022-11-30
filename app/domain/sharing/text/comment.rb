# frozen_string_literal: true

module Sharing::Text
  class Comment
    attr_reader :comment, :user

    class << self
      def call(comment, user:)
        case comment.subject
        when ::Post, ::ProductRequest, ::Recommendation, ::UpcomingPageMessage, ::Review, ::Anthologies::Story, ::Discussion::Thread
          new(comment: comment, user: user).call
        else
          raise ArgumentError, "Unknown comment subject type #{ comment.subject.class }"
        end
      end
    end

    def initialize(comment:, user:)
      @comment = comment
      @user = user
    end

    def call
      Twitter::Message
        .new
        .add_mandatory(message_beginning)
        .add_mandatory("thoughts on #{ message_name }")
        .add_optional('on @ProductHunt')
        .add_optional("cc #{ mentioned_users.join(' ') }", if: mentioned_users.present?)
        .add_mandatory(Routes.comment_url(comment))
        .to_s
    end

    private

    def message_name
      return comment.subject_name if comment.subject_type != 'Discussion::Thread'

      "\"#{ comment.subject_name }\""
    end

    def message_beginning
      comment_user = comment.user

      return 'My' if comment_user == user
      return "💬 @#{ comment.user.twitter_username }'s" if comment_user.twitter_username.present?

      "#{ comment.user.name }'s"
    end

    def mentioned_users
      @mentioned_users ||= Sharing::MentionedTwitterUsernames.call(comment.body)
    end
  end
end
