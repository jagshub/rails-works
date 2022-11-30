# frozen_string_literal: true

module Graph::Mutations
  class PostUpdate < BaseMutation
    argument_record :post, Post, authorize: :update

    argument :name, String, required: true
    argument :tagline, String, required: true
    argument :description, String, required: false
    argument :topic_ids, [ID], required: false
    argument :angellist_url, String, required: false
    argument :twitter_url, String, required: false
    argument :facebook_url, String, required: false
    argument :github_url, String, required: false
    argument :instagram_url, String, required: false
    argument :medium_url, String, required: false
    argument :makers, [String], required: false
    argument :additional_links, [String], required: false
    argument :url, String, required: false
    argument :media, [Graph::Types::MediaRecordInputType], required: false
    argument :thumbnail_image_uuid, String, required: true
    argument :social_media_image_uuid, String, required: false
    argument :multiplier, String, required: false
    argument :featured_at, String, required: false
    argument :product_state, String, required: true
    argument :locked, Boolean, required: false
    argument :promo_text, String, required: false
    argument :promo_code, String, required: false
    argument :promo_expire_at, String, required: false
    argument :pricing_type, Graph::Types::PostPricingTypeEnum, required: false

    returns Graph::Types::PostType

    def perform(post:, **params)
      form = Posts::UpdateForm.new(post, user: current_user)
      form.update params

      form
    end
  end
end
