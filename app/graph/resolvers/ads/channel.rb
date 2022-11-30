# frozen_string_literal: true

# NOTE(DZ): It's important to note that while this resolver is called `Channel`,
# the returned object is not a channel, but a `Ads::Ad` object
#
class Graph::Resolvers::Ads::Channel < Graph::Resolvers::Base
  type Graph::Types::Ads::ChannelType, null: true

  class BundleEnum < Graph::Types::BaseEnum
    graphql_name 'AdsChannelBundleEnum'

    Ads::Channel.bundles.each do |k, v|
      value v, k
    end
  end

  argument :kind, String, required: true
  argument :bundle, BundleEnum, required: false

  def resolve(kind:, bundle: nil)
    topic_id = get_topic_id(object)

    if kind == 'bundle_priority'
      find_bundle_priority(kind: kind, topic_id: topic_id, bundle: bundle)
    else
      find_ad(kind: kind, topic_id: topic_id, bundle: bundle)
    end
  end

  private

  def get_topic_id(object)
    case object
    when Post, Product, Collection then object.topic_ids
    when Topic then object.id
    when nil then nil
    else raise "Invalid parent object class #{ object.class }"
    end
  end

  def find_ad(args)
    context.session[:served_ads] ||= []
    exclude_ids = context.session[:served_ads]
    ad = Ads.find_web_ad(**args, exclude_ids: exclude_ids)

    # NOTE(DZ): If we can't find an ad, reset exclusion
    if ad.blank?
      context.session[:served_ads] = []
      ad = Ads.find_web_ad(**args)
    end

    context.session[:served_ads] << ad.id if ad.present?

    ad
  end

  # NOTE(rstankov): Copied from `find_app`.
  #   Should be removed after `bundle_priority` experiment is over
  def find_bundle_priority(kind:, topic_id:, bundle:)
    context.session[:served_ads] ||= []
    exclude_ids = context.session[:served_ads]

    ad = Ads.find_web_ad(kind: kind, topic_id: topic_id, bundle: bundle, exclude_ids: exclude_ids)

    if ad.blank?
      ad = Ads.find_web_ad(kind: 'sidebar', topic_id: topic_id, bundle: bundle, exclude_ids: exclude_ids)
    end

    # NOTE(DZ): If we can't find an ad, reset exclusion
    if ad.blank?
      context.session[:served_ads] = []

      ad = Ads.find_web_ad(kind: kind, topic_id: topic_id, bundle: bundle, exclude_ids: [])
    end

    if ad.blank?
      ad = Ads.find_web_ad(kind: 'sidebar', topic_id: topic_id, bundle: bundle, exclude_ids: exclude_ids)
    end

    context.session[:served_ads] << ad.id if ad.present?

    ad
  end
end
