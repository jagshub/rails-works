# frozen_string_literal: true

class DownloadsController < ApplicationController
  before_action :require_user_for_cancan_auth!

  def export
    export = FileExport.find(params[:id])

    if export.user_id != current_user.id
      message = 'Please sign in with the same account you used to request your download.'
      raise KittyPolicy::AccessDenied.with_message(message)
    end

    if export.expired?
      message = 'This link has expired. Please request a new download.'
      raise KittyPolicy::AccessDenied.with_message(message)
    end

    redirect_to export.file_download_url
  end
end
