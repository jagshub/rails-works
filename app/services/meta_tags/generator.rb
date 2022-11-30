# frozen_string_literal: true

class MetaTags::Generator
  attr_reader :subject

  class << self
    def generate_for(subject)
      generator_for(subject).call
    end

    def generator_for(subject)
      generator = "::MetaTags::Generators::#{ subject.class.name }".safe_constantize
      raise NotImplementedError, "You must implement a metatag generator for #{ subject.class.name }'s" unless generator

      generator.new(subject)
    end

    def call(subject)
      new(subject).call
    end
  end

  def initialize(subject)
    @subject = subject
  end

  def call
    meta_tags = {
      canonical_url: canonical_url,
      creator: creator,
      description: description.truncate(160),
      image: image,
      robots: robots,
      title: title,
      type: type,
      oembed_url: oembed_url,
      mobile_app_url: mobile_app_url,
      author: author,
      author_url: author_url,
    }
    meta_tags.delete_if { |_, v| v.nil? }
  end

  def mobile_app_url
    nil
  end

  def canonical_url
    raise NotImplementedError, 'You must implement #canonical_url in each kind of metatag'
  end

  def oembed_url
    nil
  end

  def creator
    raise NotImplementedError, 'You must implement #creator in each kind of metatag'
  end

  def description
    raise NotImplementedError, 'You must implement #description in each kind of metatag'
  end

  def image
    raise NotImplementedError, 'You must implement #image in each kind of metatag'
  end

  def title
    raise NotImplementedError, 'You must implement #title in each kind of metatag'
  end

  def author
    nil
  end

  def author_url
    nil
  end

  def type
    'article'
  end

  def robots
    nil
  end
end
