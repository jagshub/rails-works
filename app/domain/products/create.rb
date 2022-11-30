# frozen_string_literal: true

module Products::Create
  extend self

  def for_post(post, url: nil, visible: false, product_source: 'admin')
    url ||= post.primary_link.url

    product = Product.create!(
      name: post.name,
      tagline: post.tagline,
      description: Sanitizers::HtmlToText.call(post.description, extract_attr: false),
      website_url: url,
      clean_url: UrlParser.clean_product_url(url),
      source: product_source,
      visible: visible,
    )

    Products::MovePost.call(post: post, product: product, source: product_source)
    product
  end
end
