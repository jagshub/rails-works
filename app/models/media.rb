# frozen_string_literal: true

# == Schema Information
#
# Table name: media
#
#  id              :bigint(8)        not null, primary key
#  user_id         :bigint(8)
#  subject_type    :string           not null
#  subject_id      :bigint(8)        not null
#  uuid            :string           not null
#  kind            :string           not null
#  priority        :integer          default(0), not null
#  original_width  :integer          not null
#  original_height :integer          not null
#  metadata        :json
#  original_url    :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_media_on_subject_type_and_subject_id  (subject_type,subject_id)
#  index_media_on_user_id                      (user_id)
#
class Media < ApplicationRecord
  include Prioritisable
  include RandomOrder

  SUBJECTS = [Ads::Campaign, Ads::Budget, Ads::Channel, Product, Post, Comment, ChangeLog::Entry, Products::Screenshot].freeze

  belongs_to :user, optional: true, inverse_of: :media
  belongs_to_polymorphic :subject, inverse_of: :media, allowed_classes: SUBJECTS

  enum kind: {
    image: 'image',
    video: 'video',
    audio: 'audio',
  }

  validates :kind, :uuid, :priority, presence: true
  validates :original_width, :original_height, presence: true

  store_accessor :metadata, *%i(platform video_id url kindle_asin).freeze

  # TODO(DZ): Move this into `Prioritisable`
  before_validation on: :create, if: -> { priority.blank? } do
    self.priority = pick('MAX(priority)').presence || 0 if priority.blank?
  end

  after_commit :refresh_counters, on: %i(create destroy)

  class << self
    # Note(DZ): Grey "P" Logo
    def empty_image_url
      Image.call(
        DEFAULT_POST_THUMBNAIL_UUID,
        width: 300,
        height: 300,
        fit: 'crop',
      )
    end
  end

  def media=(media)
    return if media.blank?

    upload_media = MediaUpload.store(media)

    self[:uuid] = upload_media.image_uuid
    self[:original_width] = upload_media.original_width
    self[:original_height] = upload_media.original_height
    self[:kind] = upload_media.media_type
    self[:metadata] = upload_media.metadata
  end

  def image_url(width: nil, height: nil, fit: 'crop')
    Image.call(uuid, width: width, height: height, fit: fit)
  end

  private

  def refresh_counters
    return unless subject.respond_to? :refresh_media_count

    subject.refresh_media_count
  end
end
