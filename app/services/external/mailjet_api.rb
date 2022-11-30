# frozen_string_literal: true

module External::MailjetApi
  extend self

  PRODUCTION_ACCOUNT_CONFIG = {
    api_key: ENV['MAILJET_PUBLIC_KEY'],
    secret_key: ENV['MAILJET_PRIVATE_KEY'],
  }.freeze

  def with_producthunt_account
    with_config(PRODUCTION_ACCOUNT_CONFIG) do
      yield
    end
  end

  def with_transactional_account
    with_config(CommunityContact.delivery_method_options) do
      yield
    end
  end

  def add_contact_to_list(name:, email:, list_id:)
    create_contact(name: name, email: email)
    with_config(PRODUCTION_ACCOUNT_CONFIG) do
      resp = Mailjet::Listrecipient.create(
        contact_alt: email,
        list_id: list_id,
      )
      return resp.attributes['Data']
    rescue StandardError => e
      raise e unless e.message.include? 'duplicate ListRecipient already exists'

      update_contact_state_in_list(email: email, list_id: list_id, action: 'addforce')
    end
  end

  def remove_contact_from_list(user_email:, list_id:)
    update_contact_state_in_list(email: user_email, list_id: list_id, action: 'remove')
  end

  def gdpr_delete(user_email:)
    with_config(PRODUCTION_ACCOUNT_CONFIG) do
      mailjet_contact = Mailjet::Contact.find(user_email)
      return false if mailjet_contact.nil?

      # NOTE(TDC): Mailjet Contact Deletion Doc https://dev.mailjet.com/email/guides/contact-management/#gdpr-delete-contacts
      # v4 not supported by gem yet
      HTTParty.delete(
        "https://api.mailjet.com/v4/contacts/#{ mailjet_contact.attributes[:id] }",
        basic_auth: {
          username: PRODUCTION_ACCOUNT_CONFIG[:api_key],
          password: PRODUCTION_ACCOUNT_CONFIG[:secret_key],
        },
      )
    end
  end

  def statcounters(id:, from:, to:, source: 'Campaign', resolution: 'day', timing: 'event', limit: 10)
    Mailjet::Statcounters.all(
      source_id: id,
      counter_source: source,
      counter_timing: timing,
      counter_resolution: resolution,
      from_ts: (from.is_a?(Numeric) ? from : from.to_i),
      to_ts: (to.is_a?(Numeric) ? to : to.to_i),
      limit: limit,
    )
  end

  def create_contact_list(product_id)
    with_config(PRODUCTION_ACCOUNT_CONFIG) do
      resp = Mailjet::Contactslist.create(
        name: "Product Announcements #{ product_id }",
      )
      resp.attributes['Data']['Data'][0]['ID'] if resp.attributes['Data']
    end
  end

  private

  def update_contact_state_in_list(email:, list_id:, action:)
    with_config(PRODUCTION_ACCOUNT_CONFIG) do
      resp = Mailjet::Contactslist_managemanycontacts.create(
        id: list_id, action: action, contacts: [{ 'email' => email }],
      )
      return resp.attributes['Data']
    rescue Mailjet::ApiError => e
      return if e.message.include? 'Object not found'

      raise e
    end
  end

  def get_contact(email:)
    with_config(PRODUCTION_ACCOUNT_CONFIG) do
      Mailjet::Contact.find(email)
    end
  end

  def create_contact(name:, email:)
    return if get_contact(email: email)

    with_config(PRODUCTION_ACCOUNT_CONFIG) do
      Mailjet::Contact.create(name: name, email: email)
    end
  end

  # NOTE(DZ): Possibly not threadsafe
  def with_config(options)
    old_api_key = Mailjet.config.api_key
    old_secret_key = Mailjet.config.secret_key

    begin
      Mailjet.configure do |config|
        config.api_key = options[:api_key]
        config.secret_key = options[:secret_key]
      end

      yield
    ensure
      Mailjet.configure do |config|
        config.api_key = old_api_key
        config.secret_key = old_secret_key
      end
    end
  end
end
