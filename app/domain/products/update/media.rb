# frozen_string_literal: true

class Products::Update::Media
  attr_reader :product, :user, :media, :media_attributes

  class << self
    def call(*args)
      new(*args).call
    end
  end

  def initialize(product:, user:, media:)
    @product = product
    @user = user
    @media = media
    @media_attributes = Array(media)
  end

  def call
    update_media unless media.nil?
  end

  private

  def update_media
    product.media.where.not(id: media_ids_to_keep).destroy_all

    media_attributes.each do |attributes|
      create_media(attributes) if attributes[:id].blank?
    end
  end

  def media_ids_to_keep
    media_attributes.map { |a| a[:id] }.compact
  end

  def create_media(attributes)
    product.media.create!(
      user: user,
      uuid: attributes[:image_uuid],
      kind: attributes[:media_type],
      metadata: normalize_metadata(attributes[:metadata] || {}),
      original_height: attributes[:original_height],
      original_width: attributes[:original_width],
    )
  end

  def normalize_metadata(metadata)
    metadata.transform_keys { |key| key.to_s.underscore }
  end
end
