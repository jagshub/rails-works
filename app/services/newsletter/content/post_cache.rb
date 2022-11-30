# frozen_string_literal: true

class Newsletter::Content::PostCache
  def initialize
    @cache = {}
  end

  def add(posts)
    @cache.merge! posts.map { |p| [p.id.to_i, p] }.to_h
  end

  def [](post_id)
    @cache[post_id.to_i]
  end

  def get(post_ids)
    Array(post_ids).map { |id| @cache[id.to_i] }
  end

  def post_ids
    @cache.keys
  end
end
