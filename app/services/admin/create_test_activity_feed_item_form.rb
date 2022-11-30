# frozen_string_literal: true

module Admin::CreateTestActivityFeedItemForm
  extend self

  FEED_ITEMS = {
    'CommentCreated' => Stream::Activities::CommentCreated,
    'DiscussionStarted' => Stream::Activities::DiscussionStarted,
    'PostHunted' => Stream::Activities::PostHunted,
    'PostLaunched' => Stream::Activities::PostLaunched,
    'ProductPostLaunched' => Stream::Activities::ProductPostLaunch,
    'PostMakerListed' => Stream::Activities::PostMakerListed,
    'ReviewCreated' => Stream::Activities::ReviewCreated,
    'UpcomingPageLaunched' => Stream::Activities::UpcomingPageLaunched,
    'UpcomingPageSubscribed' => Stream::Activities::UpcomingPageSubscribed,
    'UserFollowed' => Stream::Activities::UserFollowed,
    'VoteCreated' => Stream::Activities::VoteCreated,
  }.freeze

  SUBJECTS = {
    'CommentCreated' => Comment,
    'DiscussionStarted' => Discussion::Thread,
    'PostHunted' => Post,
    'PostLaunched' => Post,
    'ProductPostLaunched' => Post,
    'PostMakerListed' => Post,
    'ReviewCreated' => Review,
    'UpcomingPageLaunched' => UpcomingPage,
    'UpcomingPageSubscribed' => UpcomingPage,
    'UserFollowed' => User,
    'VoteCreated' => Vote,
  }.freeze

  def create(user_id:, feed_item_type:, subject_id:, actor_id:)
    return [false, 'Enter all values'] if user_id.blank? || feed_item_type.blank? || subject_id.blank?

    return [false, 'Invalid feed type'] unless FEED_ITEMS[feed_item_type]

    user = User.find_by(id: user_id)
    actor = actor_id.present? ? User.find_by(id: actor_id) : user

    return [false, 'Invalid receiver'] unless user
    return [false, 'Invalid actor'] unless actor

    subject = SUBJECTS.fetch(feed_item_type).find_by(id: subject_id)

    if feed_item_type == 'UserFollowed'
      actor = subject
      subject = UserFriendAssociation.find_by(
        following_user: user,
        followed_by_user: subject,
      )

      return [false, "#{ actor.name } should follow #{ user.name } to create activity"] if subject.nil?
    end

    return [false, 'Invalid subject'] unless subject

    fake_event = FakeEvent.new(subject: subject)

    activity = FEED_ITEMS.fetch(feed_item_type).new

    feed_item = activity.send(:create_item_for_receiver, activity.class.create_behaviour, user_id,
                              actor: actor,
                              verb: activity.class.verb_name,
                              object: activity.fetch_object(fake_event),
                              target: activity.fetch_target(fake_event),
                              last_occurrence_at: Time.current)

    Stream::Workers::FeedItemsSyncData.perform_now(item_ids: [feed_item.id], feed_items_are_similar: true)

    [true, 'Created successfully']
  end

  class FakeEvent
    attr_reader :name, :subject, :user, :payload

    def initialize(subject:)
      @name = 'test'
      @subject = subject
      @user = User.admin.first
      @payload = {}

      @time = Time.current
    end

    def subject_type
      subject.class.name
    end

    delegate :id, to: :subject, prefix: true

    delegate :id, to: :user, prefix: true

    def id
      -1
    end

    def source
      nil
    end

    def source_path
      nil
    end

    def created_at
      @time
    end

    def updated_at
      @time
    end

    def received_at
      @time
    end
  end
end
