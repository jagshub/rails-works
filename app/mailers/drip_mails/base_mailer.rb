# frozen_string_literal: true

class DripMails::BaseMailer < ApplicationMailer
  private

  TRANSACTIONAL_MAIL_OPTS = {
    delivery_method_options: CommunityContact.delivery_method_options,
    from: CommunityContact.from(name: 'The Product Hunt Team', email: CommunityContact::EMAIL),
    reply_to: CommunityContact::REPLY,
  }.freeze

  def transactional_mail(opts)
    mail TRANSACTIONAL_MAIL_OPTS.merge(opts)
  end

  def campaign_name(kind, mailer)
    ::DripMails.campaign_name_for(kind: kind, mailer: mailer)
  end
end
