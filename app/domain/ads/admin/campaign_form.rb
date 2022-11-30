# frozen_string_literal: true

class Ads::Admin::CampaignForm < Admin::BaseForm
  ATTRIBUTES = %i(
    cta_text
    name
    post_id
    tagline
    thumbnail
    thumbnail_uuid
    url
    url_params
  ).freeze

  MEDIA_ATTRIBUTES = %i(id media image_uuid priority _destroy).freeze

  model :campaign,
        attributes: ATTRIBUTES,
        nested_attributes: { media: MEDIA_ATTRIBUTES },
        save: true

  main_model :campaign, Ads::Campaign

  delegate :thumbnail_url, to: :campaign

  def initialize(campaign = nil)
    @campaign = campaign || Ads::Campaign.new
  end

  def update(attrs)
    if attrs[:post_id].present?
      post_details = get_post_details(attrs[:post_id])
      attrs = post_details.merge(attrs.select { |_k, v| v.present? })
    end

    attrs.delete(:thumbnail_uuid) if attrs[:thumbnail].present?

    super(attrs)
  end

  def url=(url)
    @campaign.url = url.strip
  end

  def url_params
    @campaign.url_params.to_query
  end

  def url_params=(param_string)
    @campaign.url_params = Rack::Utils.parse_nested_query(param_string)
  end

  private

  def get_post_details(post_id)
    post = Post.find_by_id(post_id)

    return {} if post.blank?

    ActionController::Parameters.new(
      name: post.name,
      tagline: post.tagline,
      thumbnail_uuid: post.thumbnail_image_uuid,
      url: post.url,
    ).permit!
  end
end
