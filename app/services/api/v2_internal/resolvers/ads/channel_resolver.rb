# frozen_string_literal: true

class API::V2Internal::Resolvers::Ads::ChannelResolver < Graph::Resolvers::Base
  type API::V2Internal::Types::Ads::ChannelType, null: true

  class BundleEnum < Graph::Types::BaseEnum
    graphql_name 'AdsChannelBundleEnum'

    Ads::Channel.bundles.each do |k, v|
      value v, k
    end

    value 'homepage', 'deprecated: use homepage_primary'
    value 'homepage_2', 'deprecated: use homepage_other'
  end

  argument :kind, String, required: true
  argument :bundle, BundleEnum, required: false

  def resolve(args = {})
    topic_id = get_topic_id(object)

    # NOTE(DZ): For legacy apps without proper UserAgent formatting, just
    # look for iOS
    Ads.find_ios_ad(
      kind: args[:kind],
      topic_id: topic_id,
      bundle: temporary_bundle_migration(args[:bundle]),
    )
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

  # NOTE(DZ): Temporary fix for renaming channels
  def temporary_bundle_migration(bundle)
    case bundle
    when 'homepage'
      'homepage_primary'
    when 'homepage_2'
      'homepage_other'
    else
      bundle
    end
  end
end
