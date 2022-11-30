# frozen_string_literal: true

class Newsletter::Content
  delegate(
    :anthologies_story,
    :daily?,
    :date,
    :date_range,
    :id,
    :slug,
    :kind,
    :meetup_event,
    :primary_section,
    :image_uuid,
    :sections,
    :sponsor,
    :skip_sponsor?,
    :sponsor_title,
    :subject,
    :weekend_newsletter?,
    :weekly?,
    :social_image_url,
    to: '@newsletter',
  )

  attr_reader :top_items

  RECOMMENDED_POSTS_LIMIT = 10

  def initialize(newsletter, for_user_id: nil, cache: nil)
    @newsletter = newsletter
    @for_user_id = for_user_id
    @top_items = fetch_top_posts(cache) if cache
  end

  def top_items
    @top_items ||= fetch_top_posts
  end

  def recent_upvotes
    @recent_upvotes ||= Vote.where(subject_type: 'Post', user_id: @for_user_id)
                            .where('created_at > :date', date: 10.days.ago)
                            .pluck(:subject_id)
  end

  # TODO(DZ): This will be unused with deprecation of old newsletter ad method
  def ad
    @ad = @newsletter.promoted_product || @newsletter.ad
  end

  def user?
    @for_user_id.present?
  end

  private

  def fetch_top_posts(cache = nil)
    loader = PostLoader.new(cache: cache)
    loader.schedule_posts @newsletter.posts.map { |p| p['id'] }
    loader.fetch_posts

    ::Newsletter::Content::TopPostItem.from_array(@newsletter.posts, loader)
  end
end
