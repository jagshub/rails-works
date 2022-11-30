# frozen_string_literal: true

class MetaTags::Generators::ProductRequest < MetaTags::Generator
  def mobile_app_url
    MetaTags::MobileAppUrl.perform(subject)
  end

  def canonical_url
    product_request = subject.duplicate_of || subject
    Routes.product_request_url(product_request)
  end

  def robots
    'noindex, nofollow' if subject.duplicate? || subject.hidden?
  end

  def oembed_url
    Routes.product_request_url(subject)
  end

  def creator
    return if subject.anonymous?

    format('@%s', subject.user.username)
  end

  # NOTE(ayrton): Strip out any HTML to show text only
  def description
    subject.seo_description.presence || ActionView::Base.full_sanitizer.sanitize(subject.body)
  end

  def image
    Sharing.image_for(subject)
  end

  def title
    if subject.seo_title.present?
      formatted_title = format(subject.seo_title, subject.recommended_products_count)
      formatted_title.to_s
    else
      format('%s', subject.title)
    end
  end
end
