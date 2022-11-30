# frozen_string_literal: true

module Graph::Mutations
  class UpdateUpcomingPage < BaseMutation
    argument_record :upcoming_page, UpcomingPage, authorize: :update, required: true

    argument :name, String, required: false
    argument :tagline, String, required: false
    argument :success_text, Graph::Types::HTMLType, required: false

    argument :who_text, Graph::Types::HTMLType, required: false
    argument :what_text, Graph::Types::HTMLType, required: false
    argument :why_text, Graph::Types::HTMLType, required: false
    argument :logo_uuid, String, required: false
    argument :brand_color, String, required: false
    argument :background_image_uuid, String, required: false
    argument :thumbnail_uuid, String, required: false
    argument :unsplash_background_url, String, required: false
    argument :template_name, String, required: false
    argument :background_color, String, required: false
    argument :website_url, String, required: false
    argument :app_store_url, String, required: false
    argument :play_store_url, String, required: false
    argument :facebook_url, String, required: false
    argument :twitter_url, String, required: false
    argument :angellist_url, String, required: false
    argument :privacy_policy_url, String, required: false
    argument :seo_title, String, required: false
    argument :seo_description, String, required: false
    argument :seo_image_uuid, String, required: false

    argument :media, Graph::Types::MediaInputType, required: false

    argument :variant_b_status, String, required: false
    argument :variant_b_who_text, Graph::Types::HTMLType, required: false
    argument :variant_b_what_text, Graph::Types::HTMLType, required: false
    argument :variant_b_why_text, Graph::Types::HTMLType, required: false
    argument :variant_b_logo_uuid, String, required: false
    argument :variant_b_brand_color, String, required: false
    argument :variant_b_background_image_uuid, String, required: false
    argument :variant_b_thumbnail_uuid, String, required: false
    argument :variant_b_unsplash_background_url, String, required: false
    argument :variant_b_template_name, String, required: false
    argument :variant_b_background_color, String, required: false
    argument :variant_b_media, Graph::Types::MediaInputType, required: false

    argument :widget_intro_message, String, required: false

    argument :topic_ids, [ID], required: false

    argument :hiring, Boolean, required: false
    argument :status, String, required: false

    argument :webhook_url, String, required: false

    returns Graph::Types::UpcomingPageType

    require_current_user

    def perform(upcoming_page:, **inputs)
      form = ::UpcomingPages::Form.new(current_user, upcoming_page)
      form.update(inputs)
      form
    end
  end
end
