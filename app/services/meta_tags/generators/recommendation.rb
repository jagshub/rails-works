# frozen_string_literal: true

class MetaTags::Generators::Recommendation < MetaTags::Generator
  def mobile_app_url
    MetaTags::MobileAppUrl.perform(recommendation)
  end

  def canonical_url
    Routes.product_request_url(product_request)
  end

  def robots
    'noindex, follow'
  end

  def oembed_url
    Routes.product_request_recommendation_url(product_request, recommendation)
  end

  def creator
    format('@%s', recommendation.user.username)
  end

  def author
    recommendation.user.name
  end

  def author_url
    Routes.profile_url(recommendation.user)
  end

  def description
    # Note (Mike Coutermarsh): full_sanitizer strips out any/all HTML. Show text only.
    "#{ recommended_product.name_with_fallback } - #{ ActionView::Base.full_sanitizer.sanitize(recommendation.body) }"
  end

  def image
    Sharing.image_for(product_request)
  end

  def title
    format('%s - %s', product_request.title, recommended_product.name_with_fallback)
  end

  def type
    'article'
  end

  private

  def recommendation
    @recommendation ||= subject
  end

  def product_request
    @product_request ||= recommendation.product_request
  end

  def recommended_product
    @recommended_product ||= recommendation.recommended_product
  end
end
