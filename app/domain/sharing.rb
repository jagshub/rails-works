# frozen_string_literal: true

module Sharing
  extend self

  def text_for(subject, user: nil)
    generator = FindConst.call(Sharing::Text, subject)

    if generator.method(:call).arity == 1
      generator.call(subject)
    else
      generator.call(subject, user: user)
    end
  end

  def image_for(subject)
    Sharing::ImageUrl.call(subject)
  end

  def find_subject(subject_type, subject_id)
    case subject_type
    when 'Post'
      Post.find(subject_id)
    when 'UpcomingEvent'
      Upcoming::Event.find(subject_id)
    when 'Comment'
      Comment.find(subject_id)
    when 'Review'
      Review.find(subject_id)
    when 'UpcomingPage'
      UpcomingPage.find(subject_id)
    when 'UpcomingPageMessage'
      UpcomingPageMessage.visibility_public.find(subject_id)
    when 'Job'
      Job.find(subject_id)
    when 'Story', 'AnthologiesStory'
      Anthologies::Story.find(subject_id)
    when 'Discussion'
      Discussion::Thread.find(subject_id)
    when 'Newsletter'
      Newsletter.find(subject_id)
    when 'Topic'
      Topic.find(subject_id)
    when 'User'
      User.find(subject_id)
    when 'Collection'
      Collection.find(subject_id)
    when 'TopPostBadge', 'GoldenKittyAwardBadge'
      Badge.find(subject_id)
    when 'DiscussionThread'
      Discussion::Thread.find(subject_id)
    when 'ChangeLog'
      ChangeLog::Entry.find(subject_id)
    when 'ProductRequest'
      ProductRequest.find(subject_id)
    when 'Recommendation'
      Recommendation.find(subject_id)
    when 'UserAwardBadge'
      Badges::UserAwardBadge.find(subject_id)
    end
  end
end
