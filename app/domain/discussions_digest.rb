# frozen_string_literal: true

module DiscussionsDigest
  extend self

  def notifications
    Stream::FeedItem
      .joins(:receiver)
      .where(verb: 'comment', target_type: ['Post', 'Discussion::Thread'], connecting_text: Stream::FeedItem::COMMENTED_ON)
      .where_time_gteq(:last_occurrence_at, 24.hours.ago)
      .where('stream_feed_items.last_occurrence_at > users.notification_feed_last_seen_at')
      .group_by(&:receiver_id)
  end

  def comment_threads_from(notifications)
    notifications.group_by { |n| find_subject(n.target_id, n.target_type) }.map do |subject, grouped_notifications|
      CommentThread.new(
        subject,
        comments_from_notifications(grouped_notifications),
      )
    end
  end

  private

  def comments_from_notifications(notifications)
    comment_ids = notifications.map { |n| n.action_objects.first.split('_').last }
    Comment.where(id: comment_ids).order(Arel.sql('parent_comment_id IS NULL DESC, id DESC'))
  end

  def find_subject(target_id, target_type)
    if target_type == 'Post'
      Post.find(target_id)
    elsif target_type == 'Discussion::Thread'
      Discussion::Thread.find(target_id)
    else
      raise 'Unknown subject type'
    end
  end

  class CommentThread
    attr_reader :subject, :subject_name, :comments_count

    def initialize(subject, comments)
      @subject = subject
      @subject_name = subject.try(:name) || subject.try(:title)
      @comments = split_parent_and_children(comments)
      @comments_count = comments.size
    end

    def each_with_children
      @comments.each do |parent, comments|
        yield parent, comments
      end
    end

    private

    def split_parent_and_children(comments)
      comments.first(3).each_with_object({}) do |comment, acc|
        if comment.parent
          acc[comment.parent] ||= []
          acc[comment.parent] << comment
        else
          acc[comment] ||= []
        end
        acc
      end
    end
  end
end
