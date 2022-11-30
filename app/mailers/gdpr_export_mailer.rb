# frozen_string_literal: true

class GdprExportMailer < ApplicationMailer
  def export_was_generated(email:, zip:)
    attachments['export.zip'] = zip

    mail from: 'Product Hunt Privacy <privacy@producthunt.com>', to: email, subject: 'GDPR Data Export'
  end
end
