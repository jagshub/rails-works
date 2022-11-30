# frozen_string_literal: true

module ApplicationEvents
  extend KittyEvents

  event :comment_created, [
    Comments::SpamCheck,
    UserBadges.buddy_system_worker,
    UserBadges.gemologist_worker,
  ]

  event :comment_updated, [
    Comments::SpamCheck,
  ]

  event :maker_group_member_created, [
    Maker::GroupMembers::NotifyWorker.set(wait: 15.minutes),
  ]

  event :maker_group_member_updated, [
    Maker::GroupMembers::NotifyWorker.set(wait: 15.minutes),
  ]

  event :upvote, [
    Posts::UpvoteTweetWorker,
    UserBadges.thought_leader_worker,
    UserBadges.contributor_worker,
  ]

  event :discussion_thread_created, [
    Discussion::Thread::FollowWorker,
    Discussion::Thread::SlackNotificationWorker,
    Discussion::Thread::EmailWorker,
  ]

  # Note (Mike Coutermarsh): Possible for votes to be deleted before the job runs. Ignore these errors. Other Objects, we want to raise an error.
  IGNORABLE_DESERIALIZATION_ERRORS = %w(
    Collection
    Comment
    Goal
    MakerGroupMember
    LegacyProductLink
    ProductMaker
    Post
    ProductRequest
    Recommendation
    Subscriber
    UserFriendAssociation
    Vote
    Discussion::Thread
  ).freeze

  handle_worker.include ActiveJobRetriesCount
  handle_worker.rescue_from ActiveJob::DeserializationError do |exception|
    if retries_count.zero?
      retry_job wait: 5.minutes
    elsif (IGNORABLE_DESERIALIZATION_ERRORS & exception.message.split).empty?
      raise
    end
  end
end
