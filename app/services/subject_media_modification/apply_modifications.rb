# frozen_string_literal: true

module SubjectMediaModification::ApplyModifications
  extend self

  # NOTE: (TC) This will copy the source UUID in S3 and make a new S3 Object with the proper filename+extension.
  # This runs through all SubjectMediaModification that are yet to be modified. If the S3 object is failed
  # to be created the DB record will not be updated.
  # If the S3 copy works, the modification record will be marked as modified and the subject's media will reflect
  # the new updated filename
  def modify
    records_modified = 0

    SubjectMediaModification.where(modified: false).find_each do |modification|
      result = copy_object_in_place modification
      next unless result

      media_subject_class = modification.subject_type.constantize
      subject = media_subject_class.find_by_id(modification.subject_id)
      next if subject.nil? # return if record has since been destroyed

      # Sometimes there are validations for a record that may already be invalid, so running update fails.
      # assigning + save! w/validate => false ensures we wont fail to update these records and since we are targeting
      # specific columns, we dont have to worry about these edge cases. This service is responsible for a single field.
      subject.assign_attributes(modification.subject_column => modification.modified_image_uuid)
      subject.save!(validate: false)
      modification.update!(modified: true)

      records_modified += 1
    end

    Rails.logger.info "#{ records_modified } subject media records updated to new UUID."
  end

  # NOTE: (TC) This will revert all (modified: true) media modification records to be modified => false
  # It will also revert the related product media for each modification record back to the original UUID.
  # This reversion process will attempt to remove the copied S3 item w/ the new filename.
  # If the object cannot be deleted, the Media Modification record and subject's media will STILL
  # be reverted. The removal of the copied S3 file is purely for cleaning up the bucket.
  def revert
    records_modified = 0

    SubjectMediaModification.where(modified: true).find_each do |modification|
      delete_created_object modification
      media_subject_class = modification.subject_type.constantize
      subject = media_subject_class.find_by_id(modification.subject_id)
      next if subject.nil? # return if record has since been destroyed

      # Sometimes there are validations for a record that may already be invalid, so running update fails.
      # assigning + save! w/validate => false ensures we wont fail to update these records and since we are targeting
      # specific columns, we dont have to worry about these edge cases. This service is responsible for a single field.
      subject.assign_attributes(modification.subject_column => modification.original_image_uuid)
      subject.save!(validate: false)
      modification.update!(modified: false)

      records_modified += 1
    end
    Rails.logger.info "#{ records_modified } product media records reverted to original UUID."
  end

  private

  # NOTE: (TC) This will create a record inside of the ph-files bucket that is an essential duplicate of the original image with
  # the updated filename, it will then be cached by Imgix automatically. We can then update the subject's record
  # to the new filename. Since the file exists we are all good for image presentation.
  def copy_object_in_place(modification)
    External::S3Api.copy_object(bucket: :images, existing_key: modification.original_image_uuid, new_key: modification.modified_image_uuid) if Rails.env.production?
    true
  rescue StandardError
    Raven.capture_message 'SubjectMediaModification.copy_object_in_place', extra: { original: modification.modified_image_uuid, record_id: modification.id }
    false
  end

  def delete_created_object(modification)
    External::S3Api.delete_object(bucket: :images, key: modification.modified_image_uuid) if Rails.env.production?
    true
  rescue StandardError
    Raven.capture_message 'SubjectMediaModification.delete_created_object', extra: { original: modification.modified_image_uuid, record_id: modification.id }
    false
  end
end
