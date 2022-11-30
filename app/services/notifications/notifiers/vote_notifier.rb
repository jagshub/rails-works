# frozen_string_literal: true

module Notifications::Notifiers::VoteNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      mobile_push: {
        priority: :optional,
        delivery: 'immediate',
        user_setting: :send_vote_push,
      },
    }
  end

  ELIGIBLE_SUBJECTS = ['Comment', 'Post', 'Discussion::Thread'].freeze

  def fan_out?(vote)
    return false if vote.subject.blank?

    ELIGIBLE_SUBJECTS.include? vote.subject.class.name
  end

  def user_ids(object)
    if object.subject.is_a? Post
      # (Note):jag  Also include makers, but filter makers that can receive push.
      post = object.subject
      user_ids = [post.user_id] | post.makers.pluck(:user_id)
      return Mobile::Device.enabled_push_for(user_id: user_ids).pluck(:user_id)
    end
    [object.subject.user_id]
  end

  def send_notification?(notification_event, _channel)
    return false if notification_event.notifyable.blank?
    return false if notification_event.notifyable.subject.blank?

    notification_event.subscriber.user != notification_event.notifyable.user
  end

  def push_text_heading(notification_event)
    vote = notification_event.notifyable
    text = get_subject_name(vote)
    %(#{ vote.user.name } upvoted your #{ text })
  end

  def push_text_body(notification_event)
    vote = notification_event.notifyable
    body = get_body(vote)
    %(#{ vote.user.name } upvoted your #{ get_subject_name(vote) }: #{ body })
  end

  def push_text_oneliner(notification_event)
    vote = notification_event.notifyable
    body = get_body(vote)
    %(#{ vote.user.name } upvoted your #{ get_subject_name(vote) }: #{ body })
  end

  def thumbnail_url(notification_event)
    upvoter = notification_event.notifyable.user
    Users::Avatar.url_for_user(upvoter, size: 80)
  end

  private

  def get_subject_name(vote)
    case vote.subject
    when Discussion::Thread
      'Discussion'
    else
      vote.subject.class.name
    end
  end

  def get_body(vote)
    case vote.subject
    when Post then BetterFormatter.strip_tags(vote.subject.name)
    when Comment then BetterFormatter.strip_tags(vote.subject.body.truncate(250))
    when Discussion::Thread then BetterFormatter.strip_tags(vote.subject.title.truncate(250))
    else raise " object: #{ vote.subject } not eligible for notification"
    end
  end
end
