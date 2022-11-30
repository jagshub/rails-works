# frozen_string_literal: true

module Posts::Submission::SetAdditionalLinks
  extend self

  def call(post:, user:, links:)
    return if links.nil?

    primary_link = post.primary_link

    additional_links = links.without(primary_link.url).map do |url|
      url = post.links.find_or_initialize_by(url: url, post: post)
      url.user ||= user
      url
    end

    reset_primary_link(post)

    post.links = [primary_link] + additional_links

    post
  end

  private

  def reset_primary_link(post)
    return unless post.primary_link.broken?

    not_broken_link = post.links.find { |link| !link.broken }

    return if not_broken_link.blank?

    Post.transaction do
      post.primary_link.update!(primary_link: false)
      not_broken_link.update!(primary_link: true)
    end
  end
end
