# frozen_string_literal: true

class Graph::Resolvers::Ads::NewsletterPost < Graph::Resolvers::Base
  argument :force_post, String, required: false

  type Graph::Types::Ads::NewsletterType, null: true

  def resolve(force_post: nil)
    return unless object.is_a?(Newsletter::Content)

    ad = find_forced_ad(force_post) if force_post.present?
    ad ||= object.ad if object.ad.present?
    ad ||= Ads.for_newsletter_post_ads(max_only: true).sample

    ad
  end

  private

  def find_forced_ad(force_post)
    return unless current_user&.admin?

    Ads::Newsletter.find_by(id: force_post)
  end
end
