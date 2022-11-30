# frozen_string_literal: true

class Notifications::Channels::Email::Base
  attr_reader :notification

  def initialize(notification)
    @notification = notification
  end

  def deliver_now
    return if notification.blank?

    keys = CommunityContact.delivery_method_options || {}

    email = Mailjet::Send.create(
      from_email: from_email,
      from_name: from_name,
      subject: email_subject,
      "Mj-TemplateID": template_id,
      "Mj-TemplateLanguage": 'true',
      "Mj-campaign": campaign,
      to: to_email,
      cc: cc_emails.join(', '),
      headers: reply_header,
      api_key: keys[:api_key],
      secret_key: keys[:secret_key],
      vars: convert_nil_to_empty_string(template_variables).merge(unsubscribe_url: unsubscribe_url),
    )

    email
  end

  # Mailjet doesn't handle nil values when expecting a string.
  def convert_nil_to_empty_string(hash)
    hash.transform_values { |v| v.nil? ? '' : v }
  end

  def to_email
    if Rails.env.production?
      notification.subscriber.email
    else
      # Note(Mike): Protect us from accidently emailing real people outside of production.
      'dev+mailjetemailfromdev@producthunt.com'
    end
  end

  def campaign
    'other_transactional'
  end

  def cc_emails
    []
  end

  def reply_header
    {}
  end

  def from_email
    CommunityContact::PH_EMAIL
  end

  def from_name
    CommunityContact::PH_NAME
  end

  def email_subject
    raise NotImplementedError, 'must define email_subject'
  end

  # Mailjet template id
  #   Get from here: https://app.mailjet.com/templates/transactional
  def template_id
    raise NotImplementedError, 'must define template_id'
  end

  # Variables defined in the Mailjet template
  def template_variables
    raise NotImplementedError, 'must define template_variables'
  end

  # Note(Mike): in Mailjet, this is technically just another template variable.
  #   Giving it it's own method because it is really important not to forget.
  def unsubscribe_url
    raise NotImplementedError, 'must define unsubscribe_url'
  end
end
