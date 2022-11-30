# frozen_string_literal: true

class Newsletter::Content::PostLoader
  attr_reader :used_post_ids

  def initialize(cache: nil)
    @used_post_ids = []
    @cache = cache || Newsletter::Content::PostCache.new
    @already_once_loaded = false
  end

  def schedule_posts(post_ids)
    post_ids = post_ids.map(&:to_i)

    @used_post_ids.concat post_ids
  end

  def get(post_ids)
    return [] unless Array(post_ids).any?
    raise 'Posts should be only be fetched once to avoid performance problems' if @already_once_loaded == false

    posts = @cache.get(post_ids)

    posts
  end

  def fetch_posts
    raise 'Posts should be only be fetched once to avoid performance problems' if @already_once_loaded == true

    @already_once_loaded = true

    return unless unfetched_ids.any?

    posts = Post.where(id: unfetched_ids)

    @cache.add posts
  end

  private

  def unfetched_ids
    @used_post_ids - @cache.post_ids
  end
end
