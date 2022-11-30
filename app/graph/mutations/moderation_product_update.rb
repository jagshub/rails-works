# frozen_string_literal: true

module Graph::Mutations
  class ModerationProductUpdate < BaseMutation
    argument_record :product, Product, required: true, authorize: :moderate

    argument :logo_uuid, String, required: false
    argument :name, String, required: false
    argument :tagline, String, required: false
    argument :description, String, required: false
    argument :slug, String, required: false
    argument :website_url, String, required: false
    argument :twitter_url, String, required: false
    argument :facebook_url, String, required: false
    argument :instagram_url, String, required: false
    argument :media, [Graph::Types::MediaInputType], required: false
    argument_records :posts, Post, required: true

    returns Graph::Types::ProductType

    def perform(product:, posts:, media:, **inputs)
      return product unless product.update(**inputs)

      save_media(product, media)
      save_post_associations(product, posts.map(&:id))

      product
    end

    private

    def save_media(product, media)
      new_media_ids = media.pluck(:id).map(&:to_s).compact

      # Destroy old media
      product.media.each do |media_record|
        media_record.destroy unless media_record.id.to_s.in?(new_media_ids)
      end

      # Create new media
      media.reverse_each.with_index do |media_item, index|
        if media_item[:id].blank?
          create_media(product, media_item, index)
        else
          media_record = Media.find_by(id: media_item[:id])

          if media_record.present? &&
             media_record.subject_type == 'Product' &&
             media_record.subject_id == product.id
            media_record.update!(priority: index)
          else
            # then we should copy it, leave the post-connected one alone
            create_media(product, media_item, index)
          end
        end
      end

      product.refresh_media_count
      product.refresh_review_counts
    end

    def save_post_associations(product, new_post_ids)
      Products::SetProductPostIds.call(
        product: product,
        post_ids: new_post_ids,
        source: :moderation,
        reassociate: true,
      )
    end

    def create_media(product, attributes, priority)
      product.media.create!(
        uuid: attributes[:image_uuid],
        kind: attributes[:media_type],
        metadata: normalize_metadata(attributes[:metadata] || {}),
        original_height: attributes[:original_height],
        original_width: attributes[:original_width],
        priority: priority,
      )
    end

    def normalize_metadata(metadata)
      metadata.transform_keys { |key| key.to_s.underscore }
    end
  end
end
