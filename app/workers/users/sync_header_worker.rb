# frozen_string_literal: true

module Users
  class SyncHeaderWorker < ApplicationJob
    include ActiveJobHandleNetworkErrors

    rescue_from MediaUpload::UploadError do
      # ignore
    end

    def perform(user_id, medium:, overwrite:)
      user = User.not_trashed.find_by_id(user_id)

      return if user.blank?

      Users::SyncHeader.call(user, medium: medium, overwrite: overwrite)
    end
  end
end
