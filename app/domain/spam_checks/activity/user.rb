# frozen_string_literal: true

class SpamChecks::Activity::User < SpamChecks::Activity::Base
  ACTIVITIES_USING_HIDE = %w(Review).freeze

  def initialize(new_user, request_info)
    super(new_user, request_info)
  end

  def actor
    @record
  end

  def mark_as_spam
    @record.spammer!

    USER_ACTIVITIES.each do |activity_name, scope_block|
      scope = scope_block.call @record

      if activity_name == 'Vote'
        trash_votes scope.visible
      elsif ACTIVITIES_USING_HIDE.include?(activity_name)
        hide_activities scope.not_hidden
      else
        trash_activities scope.not_trashed
      end
    end
  end

  def revert_action_taken
    @record.user!

    USER_ACTIVITIES.each do |activity_name, scope_block|
      scope = scope_block.call @record

      if activity_name == 'Vote'
        revert_sandboxed_votes scope.where(sandboxed: true)
      elsif ACTIVITIES_USING_HIDE.include?(activity_name)
        revert_hidden_activities scope.hidden
      else
        revert_trashed_activities scope.trashed
      end
    end
  end

  def skip_spam_check?
    false
  end

  USER_ACTIVITIES = {
    'Vote' => ->(user) { user.votes },
    'Comment' => ->(user) { user.comments },
    'Discussion::Thread' => ->(user) { user.discussion_threads },
    'Post' => ->(user) { user.posts },
    'Review' => ->(user) { user.reviews },
  }.freeze

  private

  def trash_activities(scope)
    scope.find_each(&:trash)
  end

  def hide_activities(scope)
    scope.find_each(&:hide!)
  end

  def trash_votes(scope)
    scope.find_each do |vote|
      ::SpamChecks::Activity.mark_as_spam vote
    end
  end

  def revert_sandboxed_votes(scope)
    scope.find_each do |vote|
      ::SpamChecks::Activity.revert_action_taken vote
    end
  end

  def revert_trashed_activities(scope)
    scope.find_each(&:restore)
  end

  def revert_hidden_activities(scope)
    scope.find_each(&:unhide!)
  end
end
