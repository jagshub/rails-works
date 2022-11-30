# frozen_string_literal: true

class MetaTags::Generators::Topic < MetaTags::Generator
  def mobile_app_url
    MetaTags::MobileAppUrl.perform(subject)
  end

  def canonical_url
    @canonical_url ||= Routes.topic_url(subject.slug)
  end

  def title
    "The Best #{ subject.name } Apps and Products of #{ Time.zone.now.year }"
  end

  def description
    return "Discover the top products in #{ subject.name } on Product Hunt" if subject.posts_count == 0

    "Find the best #{ subject.name } apps on Product Hunt. Top #{ posts_count } products: #{ top_posts }"
  end

  def image
    Image.call Topics::ImageUuid.call(subject)
  end

  def creator
    '@producthunt'
  end

  private

  def top_posts
    subject.posts.by_credible_votes.limit(10).pluck(:name).to_sentence
  end

  def posts_count
    [subject.posts_count, 10].min
  end
end
