# frozen_string_literal: true

module Notifications::Helpers::GetMentionedMakerUserIds
  extend self

  def for_text(text)
    product_slugs = []
    maker_ids = []

    Nokogiri::HTML(text).css('a').map do |el|
      href = el['href']
      slug = ExtractSlug.from_url(href, 'posts')

      # Note (TC): Since we can take in arbituary links here, ExtractSlug
      # will only provide us PH links, but it is possible the returned value could be "slug/reviews"
      # or another path past the initial slug. In this case we dont want to alert the makers.
      # It is also possible to hand type these links, so trailing slashes must also be accounted for.
      # ex: producthunt.com/posts/slug/
      next if slug.nil? || slug.split('/').count > 1

      product_slugs.push(slug.chomp('/'))
    end

    product_slugs.map do |slug|
      post = ::Post.find_by_slug(slug)
      maker_ids.push(post.makers.pluck(:id)) unless post.nil?
    end

    maker_ids.flatten.uniq
  end
end
