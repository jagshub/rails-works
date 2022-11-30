# frozen_string_literal: true

# Resources:
# https://developers.google.com/search/docs/data-types/software-app
#
module StructuredData::Generators::Product
  extend self

  def structured_data_for(product)
    {
      '@context': 'http://schema.org',
      '@type': type_for(product),
      'name': name_for(product),
      'description': description_for(product),
      'datePublished': date_published_for(product),
      'dateModified': date_modified_for(product),
      'image': image_for(product),
      'screenshot': screenshots_for(product),
      'aggregateRating': rating_for(product),
      'operatingSystem': operating_system_for(product),
      'offers': offer_for(product),
      'applicationCategory': application_category_for(product),
      'author': authors_for(product),
    }
  end

  private

  def type_for(product)
    delegate_to_latest_post(product, :type_for) || 'SoftwareApplication'
  end

  def name_for(product)
    product.name
  end

  def description_for(product)
    product.description
  end

  def image_for(product)
    if product.logo_uuid
      Image.call(product.logo_uuid)
    else
      delegate_to_latest_post(product, :image_for) || Image.call(DEFAULT_POST_THUMBNAIL_UUID)
    end
  end

  def date_published_for(product)
    product.created_at
  end

  def date_modified_for(product)
    product.updated_at
  end

  def screenshots_for(product)
    if product.media_count > 0
      product.images.map(&:image_url)
    else
      delegate_to_latest_post(product, :screenshots_for)
    end
  end

  def rating_for(product)
    return if product.reviews_rating < 1

    {
      '@type': 'AggregateRating',
      'ratingCount': product.reviews_count,
      'ratingValue': product.reviews_rating,
      'worstRating': 1,
      'bestRating': 5,
    }
  end

  def operating_system_for(product)
    delegate_to_latest_post(product, :operating_system_for)
  end

  def offer_for(product)
    delegate_to_latest_post(product, :offer_for)
  end

  def application_category_for(product)
    delegate_to_latest_post(product, :application_category_for)
  end

  def authors_for(product)
    makers = product.visible_makers.map { |maker| ::StructuredData::Types::Person.call(maker) }
    makers.compact.take(3)
  end

  def delegate_to_latest_post(product, method)
    product.latest_post &&
      StructuredData::Generators::Post.send(method, product.latest_post)
  end
end
