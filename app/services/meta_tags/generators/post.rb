# frozen_string_literal: true

class MetaTags::Generators::Post < MetaTags::Generator
  def mobile_app_url
    MetaTags::MobileAppUrl.perform(subject)
  end

  def canonical_url
    Routes.post_url(subject)
  end

  def oembed_url
    Routes.post_url(subject)
  end

  def creator
    return '@producthunt' if subject.visible_makers.blank?

    format('@%s', subject.visible_makers.first.username)
  end

  def title
    "#{ subject.name } - #{ subject.tagline.strip.chomp('.') }"
  end

  def description
    description_text = Sanitizers::HtmlToText.call(subject.description)
    return description_text if description_text.present?

    description = []
    description << "#{ subject.name } - #{ subject.tagline }."
    description << "(#{ topic_names })" if subject.topics.count > 1
    description << "Read the opinion of #{ subject.comments.count } influencers." if subject.comments.count > 5
    if subject.new_product && subject.new_product.alternatives_count > 1
      description << "Discover #{ subject.new_product.alternatives_count } alternatives like #{ alternative_names }"
    end
    description.join(' ')
  end

  def image
    Sharing.image_for(subject)
  end

  def robots
    'noindex, nofollow' unless subject.featured?
  end

  def topic_names
    subject.topics.limit(3).pluck(:name).to_sentence
  end

  def type
    'product'
  end

  def alternative_names
    subject.new_product.alternatives.by_credible_votes.limit(2).pluck(:name).to_sentence
  end

  def author
    return if subject.visible_makers.blank?

    subject.visible_makers.first.name
  end

  def author_url
    return if subject.visible_makers.blank?

    Routes.profile_url(subject.visible_makers.first.username)
  end
end
