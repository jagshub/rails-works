# frozen_string_literal: true

class Stream::Workers::FeedItemsSyncData < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(target: nil, item_ids: nil, feed_items_are_similar: false)
    @reuse_data = feed_items_are_similar

    scope = feed_items_scope(target, item_ids)
    scope.find_each do |feed_item|
      data = build_data(feed_item)
      next if data.blank?

      feed_item.update!(data: data)
      feed_item.receiver.update!(notification_feed_last_seen_at: Time.current) if feed_item.receiver.notification_feed_last_seen_at.blank?
      feed_item.receiver.refresh_notification_feed_items_unread_count
    end
  end

  private

  def feed_items_scope(target, item_ids)
    return Stream::FeedItem.where(id: [item_ids]) if item_ids.present?
    return Stream::FeedItem.none if target.blank?

    scope = Stream::FeedItem.for_target(target)
    scope = scope.or(Stream::FeedItem.for_action_object(target)) if target.class.name == 'Comment' || target.class.name == 'Review'
    scope
  end

  def build_data(feed_item)
    return @data if @data.present? && @reuse_data

    actors = User
             .visible
             .where(id: feed_item.actor_ids)
             .order([Arel.sql('array_position(ARRAY[?], id)'), feed_item.actor_ids])
             .map { |user| user.slice(:id, :name, :username) }
    return if actors.blank?

    target = target_data(feed_item.target, feed_item.verb)
    return if target.blank?

    context = context_data(feed_item.action_objects)
    return if context.blank?

    data = { actors: actors, target: target, context: context }
    @data = data if @reuse_data

    data
  end

  def target_data(target, verb)
    target_info = case target
                  when Anthologies::Story
                    { title: target.title, url: Routes.story_path(target) }
                  when Comment
                    # NOTE(Dhruv): When user takes action on a comment, we use the subject
                    # of the comment as the target and comment as the body. This enables
                    # having notification text like "John Doe upvoted your comment in TestApp"
                    target_data(target.subject, verb)
                  when Discussion::Thread
                    { title: target.title, url: Routes.discussion_path(target) }
                  when Job
                    { title: target.job_title, url: target.url }
                  when MakerGroup
                    { title: target.name, url: Routes.maker_group_path(target) }
                  when Post
                    { title: target.name, url: Routes.post_path(target) }
                  when Review
                    { title: target.product.name, url: Routes.review_url(target) }
                  when Product
                    { title: target.name, url: Routes.product_url(target) }
                  when UpcomingPage
                    { title: target.name, url: Routes.upcoming_page_path(target) }
                  when UpcomingPageMessage
                    { title: target.subject, url: Routes.upcoming_page_message_path(target) }
                  when User
                    { title: target.name || target.username, url: Routes.profile_path(target) }
                  when MakersFestival::Edition
                    {
                      title: "Makers Festival: #{ Sanitizers::HtmlToText.call(target.tagline) || target.name }",
                      url: Routes.makers_festival_path(target),
                    }
                  when ChangeLog::Entry
                    { title: target.title, url: Routes.change_log_url(target) }
                  when Badges::UserAwardBadge
                    { title: target.award.name, url: Routes.profile_badges_url(target.subject) }
                  else
                    ErrorReporting.report_error(Stream::Errors::Activities::TargetNotSupported.new,
                                                extra: { target: target, type: target.class.name, verb: verb })
                    nil
                  end

    if target_info.present? && target_info[:id].blank?
      target_info[:id] = target.id
      target_info[:type] = target.class.name
    end
    target_info
  end

  def context_data(action_objects)
    return if action_objects.empty?

    klass, id = action_objects.first.split('_')
    object = klass.safe_constantize.find(id)

    # NOTE(Dhruv): Incase user votes on an item, use the vote's subject
    # to build notification context
    object = object.is_a?(Vote) ? object.subject : object
    object = object.is_a?(UpcomingPageSubscriber) ? object.upcoming_page : object

    context_info =  case object
                    when Comment
                      { body: object.body, url: Routes.comment_path(object) }
                    when Discussion::Thread
                      { body: object.description, url: Routes.discussion_path(object) }
                    when Job
                      { body: object.company_name, url: object.url, image: object.image_uuid }
                    when Post
                      { body: object.tagline, image: object.thumbnail_image_uuid, url: Routes.post_path(object) }
                    when UpcomingPage
                      { body: object.tagline, image: object.thumbnail_uuid, url: Routes.upcoming_page_path(object) }
                    when Badges::UserAwardBadge
                      { body: object.award.description, image: object.award.image_uuid, url: Routes.profile_badges_url(object.subject) }
                    when Review
                      {
                        body: object.body,
                        image: object.product.logo_uuid_with_fallback,
                        url: Routes.review_url(object),
                        rating: object.rating,
                        tags: object.positive_tags.limit(3).pluck(:positive_label),
                      }
                    else
                      {}
                    end

    context_info.merge(id: object.id, type: object.class.name)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
