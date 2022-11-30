# frozen_string_literal: true

class MetaTags::Generators::Collection < MetaTags::Generator
  def mobile_app_url
    MetaTags::MobileAppUrl.perform(subject)
  end

  def canonical_url
    Routes.collection_url(subject)
  end

  def creator
    format('@%s', subject.user.username)
  end

  def author
    subject.user.name
  end

  def author_url
    Routes.profile_url(subject.user)
  end

  def description
    if subject.products_count == 0 && subject.title.blank?
      description_for_empty_collection
    else
      description_for_collection
    end
  end

  def description_for_empty_collection
    format('A product collection about %s curated by %s', subject.name, subject.user.name)
  end

  def description_for_collection
    description = []
    description << "#{ subject.title }." if subject.title?

    if subject.products_count > 0
      description << "Discover #{ subject.products_count } curated products"
      description << "like #{ top_products.to_sentence }"
    else
      description << 'Discover curated products'
    end

    description << "about #{ subject.name }"
    description << "by #{ subject.user.name }" unless subject.without_curator?
    description << "followed by #{ subject.subscriber_count } followers" if subject.subscriber_count > 0 && subject.without_curator?
    description.join(' ')
  end

  def image
    External::Url2pngApi.share_url(subject)
  end

  def robots
    'noindex, nofollow' unless subject.featured?
  end

  def title
    if subject.without_curator?
      format('%s', subject.name)
    else
      format('%s by %s', subject.name, subject.user.name)
    end
  end

  def top_products
    subject.products.by_credible_votes.limit(2).pluck(:name)
  end
end
