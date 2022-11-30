# frozen_string_literal: true

class MetaTags::Generators::Product < MetaTags::Generator
  def canonical_url
    Routes.product_url(subject)
  end

  def oembed_url
    Routes.product_url(subject)
  end

  def creator
    return '@producthunt' if subject.visible_makers.blank?

    format('@%s', subject.visible_makers.first.username)
  end

  def title
    year = Time.zone.today.year

    return "#{ subject.name } - Product Information and More #{ year }" if subject.posts_count == 0

    "#{ subject.name } - Product Information, Latest Updates, and Reviews #{ year }"
  end

  def description
    subject.description.presence || topic_names
  end

  def image
    Sharing.image_for(subject)
  end

  def topic_names
    subject.topics.limit(4).pluck(:name).to_sentence
  end

  def type
    'product'
  end

  def author
    subject.visible_makers.first&.name
  end

  def author_url
    return if subject.visible_makers.blank?

    Routes.profile_url(subject.visible_makers.first.username)
  end

  def robots
    return 'noindex, nofollow' unless subject.latest_post&.visible? || subject.product_scraper?
  end
end
