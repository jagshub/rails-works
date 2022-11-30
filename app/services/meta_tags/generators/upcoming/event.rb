# frozen_string_literal: true

class MetaTags::Generators::Upcoming::Event < MetaTags::Generator
  delegate :description, to: :subject
  delegate :creator, :author, :author_url, to: :product_generator

  def canonical_url
    Routes.product_url(subject.product)
  end

  def oembed_url
    Routes.product_url(subject.product)
  end

  def title
    "Coming soon: #{ subject.title }"
  end

  def image
    Sharing.image_for(subject)
  end

  def topic_names
    subject.product.topics.limit(4).pluck(:name).to_sentence
  end

  def type
    'product'
  end

  private

  def product_generator
    @product_generator ||= MetaTags::Generator.generator_for(subject.product)
  end
end
