# frozen_string_literal: true

# == Schema Information
#
# Table name: subject_media_modifications
#
#  id                  :bigint(8)        not null, primary key
#  subject_type        :string
#  subject_id          :integer
#  subject_column      :string
#  original_image_uuid :string
#  modified_image_uuid :string
#  modified            :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_subject_media_modifications_on_subject_column  (subject_column)
#  index_subject_media_modifications_on_subject_id      (subject_id)
#  index_subject_media_modifications_on_subject_type    (subject_type)
#
class SubjectMediaModification < ApplicationRecord
  validate :modified_image_uuid_has_extension
  validate :ensure_valid_subject_type
  validates :subject_id, uniqueness: { scope: %i(subject_type subject_column) }, on: :create

  enum subject_types: [
    # Note(TC): This is an array of string representations of models that we are
    # allowing media migrations of. Ideally you would add your model to this array
    # and run your migration, afterwards you would then remove it. This makes use of
    # the media migrations very intentional.
    'Ads::Campaign',
    'UpcomingPageVariant',
    'Job',
    'Collection',
    'Topic',
  ]

  private

  # NOTE: (TC) Rough check to ensure that we are saving likely some kind of file extension.
  # File.extname still would return '.' if only the period was present anyway.
  # This needs to be done quickly since there are a lot of records
  def modified_image_uuid_has_extension
    errors.add(:modified_image_uuid, 'has no file extension') unless modified_image_uuid.include?('.')
  end

  def ensure_valid_subject_type
    errors.add :subject_type, :invalid unless SubjectMediaModification.subject_types.include? subject_type&.to_s
  end
end
