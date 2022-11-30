# frozen_string_literal: true

# NOTE(DZ): It's important to note that while this resolver is called `Channel`,
# the returned object is not a channel, but a stitched together struct declared
# in app/domain/ads/find_ad.rb. It may be renamed sometime in the future to
# avoid misrepresenting itself
#
class Mobile::Graph::Resolvers::Ads::Channel < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::Ads::ChannelType, null: true

  class BundleEnum < Mobile::Graph::Types::BaseEnum
    graphql_name 'AdsChannelBundleEnum'

    Ads::Channel.bundles.each do |k, v|
      value v, k
    end
  end

  argument :kind, String, required: true
  argument :bundle, BundleEnum, required: false
  argument :exclude_ids, [Int], required: false

  def resolve(kind:, bundle: nil, exclude_ids: [])
    topic_id = get_topic_id(object)

    find_ad(kind: kind, topic_id: topic_id, bundle: bundle, exclude_ids: exclude_ids)
  end

  private

  def get_topic_id(object)
    case object
    when Post then object.topic_ids
    when Topic then object.id
    when nil then nil
    else raise "Invalid parent object class #{ object.class }"
    end
  end

  def find_ad(args)
    context.session[:served_ads] ||= []
    exclude_ids = args[:exclude_ids].empty? ? context.session[:served_ads] : args[:exclude_ids]

    info = Mobile::ExtractInfoFromHeaders.get_user_agent_info(context[:request])
    os = info[:os] || 'ios'

    ad = Ads.public_send("find_#{ os }_ad", **args, exclude_ids: exclude_ids)

    # NOTE(Jag): If we can't find an ad, with given exclusion
    if ad.blank?
      ad = Ads.public_send("find_#{ os }_ad", **args)
    end

    context.session[:served_ads] << ad.id if ad.present?
    ad
  end
end
