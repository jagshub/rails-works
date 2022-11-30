# frozen_string_literal: true

module Posts::Duplicates
  extend self

  def duplicated_links(post)
    duplicated_posts = find_all(post: post)

    links_array = duplicated_posts.joins(:links).pluck(:url)

    links_array += post.links.pluck(:url)
    all_links = links_array.flatten

    find_duplicates(all_links)
  end

  def find_all(post: nil, url: nil)
    return if post.blank? && url.blank?

    urls = url.presence
    urls ||= [post.primary_link.url] + post.links.pluck(:url)

    scope(post)
      .where('posts.scheduled_at >= ?', 6.months.ago)
      .not_trashed
      .not_duplicated
      .having_url(urls)
      .by_created_at
  end

  def find_duplicates(array)
    array.group_by(&:itself).select { |_k, v| v.count > 1 }.keys
  end

  private

  def scope(post)
    return Post.all if post.blank? || post.new_record?

    Post.where.not(id: post.id)
  end
end
