# frozen_string_literal: true

class Posts::Submission::SetMedia
  attr_reader(
    :post,
    :user,
    :media_attributes,
    :thumbnail_image_uuid,
    :social_media_image_uuid,
  )

  def initialize(
    post:,
    user:,
    media:,
    thumbnail_image_uuid:,
    social_media_image_uuid: nil
  )
    @post = post
    @user = user
    @media_attributes = media.nil? ? nil : Array(media)
    @thumbnail_image_uuid = thumbnail_image_uuid
    @social_media_image_uuid = social_media_image_uuid
  end

  def call
    update_thumbnail unless thumbnail_image_uuid.nil?
    update_social_media unless social_media_image_uuid.nil?
    update_media unless media_attributes.nil?
  end

  class << self
    def call(*args)
      new(*args).call
    end
  end

  private

  def update_thumbnail
    post.update!(thumbnail_image_uuid: thumbnail_image_uuid)
  end

  def update_social_media
    post.update!(social_media_image_uuid: social_media_image_uuid)
  end

  def update_media
    post.media.where.not(id: media_ids_to_keep).destroy_all

    media_attributes.reverse.each_with_index do |attributes, i|
      if attributes[:id]
        media = post.media.find_by(id: attributes[:id])
        media.update!(priority: i) if media.present?
      else
        create_media(attributes, priority: i)
      end
    end
  end

  def media_ids_to_keep
    media_attributes.map { |a| a[:id] }.compact
  end

  def create_media(attributes, priority: 0)
    post.media.create!(
      user: user,
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
