# frozen_string_literal: true

module SubjectMediaModification::CreateModificationRecords
  extend self

  # NOTE: (TC) This will create a SubjectMediaModification Record for each Subject record
  # where the UUID does not contain a .<ext> at the end of the record.
  # The two properties are the original document version and the proposed change.
  # This allows us to revert if needed. All records are created one by one.
  # subject: is a class def here, target_column is a string rep of the column name
  def call(subject:, target_column:)
    return if [subject, target_column].any?(&:nil?)

    records_created = 0
    existing_modifications = SubjectMediaModification.where(subject_type: subject, subject_column: target_column).pluck(:subject_id)
    subject_class = subject.constantize
    media_to_update = subject_class.where("#{ target_column } NOT LIKE '%.%'").where.not(id: existing_modifications)
    to_update_count = media_to_update.count
    Rails.logger.info "Will need to update #{ to_update_count } records.."

    media_to_update.find_each do |media|
      updated_filename = file_with_extension(media[target_column])
      next if updated_filename.nil?

      SubjectMediaModification.create!(
        subject_type: subject,
        subject_id: media.id,
        subject_column: target_column,
        original_image_uuid: media[target_column],
        modified_image_uuid: updated_filename,
      )

      records_created += 1
    end

    Rails.logger.info "#{ SubjectMediaModification.where(subject_type: subject, subject_column: target_column).count } out of #{ to_update_count } created"
  end

  private

  def file_with_extension(image_uuid)
    HandleNetworkErrors.call(fallback: nil) do
      resp = HTTParty.get("#{ Image::BASE_URL }/#{ image_uuid }?fm=json")
      content = JSON.parse(resp.body)
      extension = content['Content-Type'].split('/').last
      "#{ image_uuid }.#{ extension }"
    end
  end
end
