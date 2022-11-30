# frozen_string_literal: true

module Graph::Mutations
  class PostCreate < BaseMutation
    argument :url, String, required: true
    argument :name, String, required: true
    argument :tagline, String, required: true
    argument :topics, [Graph::Types::JsonType], required: false
    argument :additional_links, [String], required: false
    argument :product_state, String, required: true
    argument :description, String, required: false
    argument :thumbnail_image_uuid, String, required: true
    argument :media, [Graph::Types::MediaInputType], required: false
    argument :video_media, Graph::Types::MediaInputType, required: false
    argument :is_maker, Boolean, required: false
    argument :makers, [Graph::Types::JsonType], required: false
    argument :comment_body, String, required: false
    argument :changes_in_version, String, required: false
    argument :product_twitter_handle, String, required: false
    argument :featured_at, String, required: false
    argument :promo_text, String, required: false
    argument :promo_code, String, required: false
    argument :promo_expire_at, String, required: false
    argument :pricing_type, Graph::Types::PostPricingTypeEnum, required: false
    argument :draft_uuid, String, required: false
    argument :share_with_press, Boolean, required: false
    argument :have_raised_vc_funding, Boolean, required: false
    argument :funding_round, String, required: false
    argument :funding_amount, String, required: false
    argument :interested_in_vc_funding, Boolean, required: false
    argument :interested_in_being_contacted, Boolean, required: false
    argument :share_with_investors, Boolean, required: false
    argument :comment_prompts, [Graph::Types::CommentPromptKindEnum], required: false

    returns Graph::Types::PostType

    authorize :create, Post

    def perform(**params)
      Posts::Create.call(
        user: current_user,
        params: params,
        request_info: request_info,
      )
    end
  end
end
