# frozen_string_literal: true

module FacebookApi::Friends
  extend self

  def call(token)
    graph = FacebookApi::Koala.call token
    graph.get_connections('me', 'friends')
  rescue Koala::KoalaError, Koala::Facebook::AuthenticationError, Faraday::ConnectionFailed, Faraday::SSLError, OpenSSL::SSL::SSLError
    nil
  end
end
