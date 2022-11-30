# frozen_string_literal: true

class DripMails::DeliveryWorker < ApplicationJob
  include ActiveJobHandleMailjetErrors
  include ActiveJobHandlePostgresErrors
  include ActiveJobHandleDeserializationError
  include ActiveJobHandleNetworkErrors

  queue_as :mailers

  def perform(drip_mail:)
    drip_mail.reload
    kind = drip_mail.drip_kind.to_sym
    mailer_name = drip_mail.mailer_name.to_sym
    return if drip_mail.completed? || drip_mail.delivering?

    drip_mail.update!(delivering: true)

    begin
      sent = DripMails.mailers_for(kind: kind)[mailer_name][:action].call(drip_mail)
    rescue StandardError => e
      ErrorReporting.report_error e
    end

    drip_mail.update!(completed: true, sent_at: sent.nil? ? nil : Time.zone.now, delivering: false)
  end
end
