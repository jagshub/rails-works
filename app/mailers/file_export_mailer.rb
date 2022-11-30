# frozen_string_literal: true

class FileExportMailer < ApplicationMailer
  def export_was_generated(export:, subject:, message:)
    @export = export
    @message = message

    mail to: export.user.email, subject: subject
  end
end
