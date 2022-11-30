# frozen_string_literal: true

# Resources:
# https://developers.google.com/search/docs/data-types/software-app
module StructuredData::Generators::Post
  extend self

  def structured_data_for(post)
    {
      '@context': 'http://schema.org',
      '@type': type_for(post),
      'name': name_for(post),
      'description': description_for(post),
      'datePublished': date_published_for(post),
      'dateModified': date_modified_for(post),
      'image': image_for(post),
      'screenshot': screenshots_for(post),
      'aggregateRating': rating_for(post),
      'operatingSystem': operating_system_for(post),
      'offers': offer_for(post),
      'applicationCategory': application_category_for(post),
      'author': authors_for(post),
    }
  end

  private

  def type_for(post)
    return 'MobileApplication' unless mobile?(post)
    return 'WebApplication' unless website?(post)

    'SoftwareApplication'
  end

  def name_for(post)
    post.name
  end

  def description_for(post)
    Sanitizers::HtmlToText.call(post.description)
  end

  def image_for(post)
    post.thumbnail_url(width: nil, height: nil, fit: nil)
  end

  def date_published_for(post)
    post.created_at
  end

  def date_modified_for(post)
    post.updated_at
  end

  def screenshots_for(post)
    post.images.map(&:image_url)
  end

  def rating_for(post)
    return if post.reviews_rating < 1

    {
      '@type': 'AggregateRating',
      'ratingCount': post.reviews_count,
      'ratingValue': post.reviews_rating,
      'worstRating': 1,
      'bestRating': 5,
    }
  end

  def operating_system_for(post)
    post.links.map(&:os).compact.first
  end

  def offer_for(post)
    prices = post.links.map(&:price).compact

    return { "@type": 'Offer', 'price': 0, 'priceCurrency': 'USD' } if ['free', 'free_options'].include?(post.pricing_type)

    return if prices.empty?

    {
      "@type": 'Offer',
      'price': prices.first,
      'priceCurrency': 'USD',
    }
  end

  def application_category_for(post)
    post.topics.reject(&:platform?).map(&:name).first
  end

  def authors_for(post)
    post.visible_makers.map { |maker| ::StructuredData::Types::Person.call(maker) }.compact
  end

  def mobile?(post)
    mobile_stores = ['ios', 'android'].freeze

    mobile_links = post.links.select { |link| mobile_stores.include? link.store }.compact

    mobile_links.empty?
  end

  def website?(post)
    post.links.include? nil
  end
end
