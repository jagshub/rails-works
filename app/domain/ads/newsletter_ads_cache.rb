# frozen_string_literal: true

# NOTE(DZ): An object to deliver ads based on available inventory in the ads
# network. The object will serve ads to its best ability to meet the impressions
# requirement of the budget. Some overflow is highly likely and acceptable.
#
# The `generate_*` methods generates a weight map shaped like:
#   {
#     weight1: {
#       ad1: available_impressions,
#       ad2: available_impressions,
#     },
#     weight2: {
#       ad3: available_impressions,
#       ad4: available_impressions,
#     },
#   }
# The map is then used in the `get_*` methods to select a RANDOM ad
# from the highest weight group. The available_impressions count will be
# decremented by 1 and if the count is less than 0, the ad will be removed.
#
#
# This object is not thread safe.
#
class Ads::NewsletterAdsCache
  attr_accessor :newsletter, :sponsors_weights_map, :posts_weights_map

  def initialize(object)
    @newsletter = object.is_a?(NewsletterVariant) ? object.newsletter : object

    @sponsors_weights_map = generate_sponsors_weights_map
    @posts_weights_map = generate_posts_weights_map
  end

  def get_newsletter_sponsor
    return if newsletter.skip_sponsor?
    # NOTE(DZ): Legacy support, new newsletters will not have this
    return newsletter.sponsor if newsletter.sponsor.present?
    return if sponsors_weights_map.blank?

    max_weight = sponsors_weights_map.keys.max
    sponsors_map = sponsors_weights_map[max_weight]
    sponsor = sponsors_map.keys.sample(1).first
    sponsors_map[sponsor] -= 1
    sponsors_map.delete(sponsor) if sponsors_map[sponsor] <= 0
    sponsors_weights_map.delete(max_weight) if sponsors_map.empty?

    sponsor
  end

  def get_newsletter_post_ad
    # NOTE(DZ): Legacy support, new newsletters will not have this
    return newsletter.ad if newsletter.ad.present?
    return if posts_weights_map.blank?

    max_weight = posts_weights_map.keys.max
    posts_map = posts_weights_map[max_weight]
    post = posts_map.keys.sample(1).first
    posts_map[post] -= 1
    posts_map.delete(post) if posts_map[post] <= 0
    posts_weights_map.delete(max_weight) if posts_map.empty?

    post
  end

  private

  def generate_posts_weights_map
    Ads
      .for_newsletter_post_ads
      .group_by(&:weight)
      .transform_values do |ads_newsletters|
        ads_newsletters.to_h do |ad_newsletter|
          [ad_newsletter, ad_newsletter.budget.available_impressions]
        end
      end
  end

  def generate_sponsors_weights_map
    Ads
      .for_newsletter_sponsor
      .group_by(&:weight)
      .transform_values do |ads_newsletter_sponsors|
        ads_newsletter_sponsors.to_h do |ads_newsletter_sponsor|
          [
            ads_newsletter_sponsor,
            ads_newsletter_sponsor.budget.available_impressions,
          ]
        end
      end
  end
end
