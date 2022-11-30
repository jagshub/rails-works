# frozen_string_literal: true

class MetaTags::Generators::Newsletter::Content < MetaTags::Generator
  def mobile_app_url
    nil
  end

  def canonical_url
    Routes.newsletter_url(subject)
  end

  def description
    content = subject.primary_section&.content
    return '' if content.blank?

    Sanitizers::HtmlToText.call(content)[0..150]
  end

  def creator
    '@producthunt'
  end

  def image
    subject.social_image_url || remove_animation(subject.image_uuid)
  end

  def robots
    nil
  end

  def title
    format('%s', subject.subject)
  end

  def type
    'article'
  end

  def remove_animation(image_url)
    return image_url if image_url.blank?

    image_uri = Addressable::URI.parse(image_url)
    return image_url if image_uri&.domain.blank?

    # If it's not an imgix URL, changing query params will do nothing:
    return image_url unless image_uri.domain.ends_with?('imgix.net')

    # Only change gifs:
    return image_url unless image_uri.extname.downcase.in?(['.gif', '.webp'])

    query_values = image_uri.query_values(Array)
    query_values.delete ['auto', 'format']
    query_values.push ['fm', 'png']
    image_uri.query_values = query_values

    image_uri.to_s
  end
end
