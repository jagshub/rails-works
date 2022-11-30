# frozen_string_literal: true

class Notifications::Notifiers
  class << self
    # Note (TC) Are you about to delete a Notifier?
    # Set the KIND value to be Notifications::Notifiers::NullNotifier
    # so this wont invalidate existing notification records.
    # you can also keep the matching ENUMS value.
    KINDS = {
      'mention' => Notifications::Notifiers::MentionNotifier,
      'friend_post' => Notifications::Notifiers::NullNotifier,
      'ama_event_subscribe' => Notifications::Notifiers::NullNotifier,
      'ama_event_starting_now' => Notifications::Notifiers::NullNotifier,
      'retention_post_trending_now' => Notifications::Notifiers::NullNotifier,
      'post_topic_association' => Notifications::Notifiers::NullNotifier,
      'post_added_to_topic' => Notifications::Notifiers::NullNotifier,
      'order_complete' => Notifications::Notifiers::NullNotifier,
      'top_maker' => Notifications::Notifiers::TopMakerNotifier,
      'new_follower' => Notifications::Notifiers::NewFollowerNotifier,
      'newsletter' => Notifications::Notifiers::NewsletterNotifier,
      'newsletter_experiment' => Notifications::Notifiers::NewsletterExperimentNotifier,
      'friend_product_maker' => Notifications::Notifiers::FriendProductMakerNotifier,
      'new_collection_curator' => Notifications::Notifiers::NullNotifier,
      'recommendation_added_to_product_request' => Notifications::Notifiers::NullNotifier,
      'ship_survey_completion' => Notifications::Notifiers::ShipSurveyCompletionNotifier,
      'ship_new_conversation_message' => Notifications::Notifiers::ShipNewConversationMessageNotifier,
      'ship_new_message_comment' => Notifications::Notifiers::ShipNewMessageCommentNotifier,
      'ship_new_subscriber' => Notifications::Notifiers::ShipNewSubscriberNotifier,
      'vote' => Notifications::Notifiers::VoteNotifier,
      'maker_welcome' => Notifications::Notifiers::NullNotifier,
      'chat_mentions' => Notifications::Notifiers::NullNotifier,
      'chat_invites' => Notifications::Notifiers::NullNotifier,
      'chat_one_on_one_messages' => Notifications::Notifiers::NullNotifier,
      'maker_accepted_group_member' => Notifications::Notifiers::MakerAcceptedGroupMemberNotifier,
      'shoutout_mention' => Notifications::Notifiers::ShoutoutMentionNotifier,
      'missed_post' => Notifications::Notifiers::MissedPostNotifier,
      'product_mention' => Notifications::Notifiers::ProductMentionNotifier,
      'top_post_competition' => Notifications::Notifiers::TopPostCompetitionNotifier,
      'awarded_badges' => Notifications::Notifiers::AwardedBadgesNotifier,
      'visit_streak_ending' => Notifications::Notifiers::VisitStreakEndingNotifier,
      'community_updates' => Notifications::Notifiers::MarketingNotifier,
      'upcoming_event_launch' => Notifications::Notifiers::UpcomingEventLaunchNotifier,
    }.freeze

    ENUMS = {
      mention: 1,
      friend_post: 2,
      retention_post_trending_now: 5,
      post_topic_association: 6,
      post_added_to_topic: 7,
      order_complete: 8,
      top_maker: 9,
      new_follower: 10,
      newsletter: 11,
      friend_product_maker: 12,
      new_collection_curator: 13,
      recommendation_added_to_product_request: 14,
      ship_survey_completion: 15,
      ship_new_conversation_message: 16,
      ship_new_message_comment: 17,
      ship_new_subscriber: 18,
      vote: 19,
      maker_welcome: 20,
      newsletter_experiment: 21,
      chat_mentions: 22,
      chat_invites: 23,
      chat_one_on_one_messages: 24,
      maker_accepted_group_member: 25,
      shoutout_mention: 26,
      product_mention: 27,
      missed_post: 28,
      top_post_competition: 29,
      awarded_badges: 30,
      visit_streak_ending: 31,
      marketing: 32,
      upcoming_event_launch: 33,
    }.freeze

    def enums
      ENUMS
    end

    def for(kind)
      raise NotImplementedError, "This kind (#{ kind }) of notifier isnt implemented yet" if KINDS[kind.to_s].blank?

      KINDS[kind.to_s]
    end
  end
end
