# frozen_string_literal: true

module FacebookApi::BasicInfo
  extend self

  def call(token)
    client = FacebookApi::Koala.call token

    client.get_object('me', fields: 'id,name,email,picture.type(large)')
  rescue Koala::Facebook::AuthenticationError => e
    ErrorReporting.report_warning(e)
    nil
  end
end
