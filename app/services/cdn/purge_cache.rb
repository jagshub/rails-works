# frozen_string_literal: true

## Takes a list of URL's and purges them from the CDN
class Cdn::PurgeCache
  include HTTParty
  API_KEY = ENV.fetch('IMGIX_API_KEY')
  base_uri 'https://api.imgix.com/api/v1'

  class << self
    def call(url)
      new(url).call
    end
  end

  def initialize(url)
    @options = {
      headers: {
        'Content-Type' => 'application/vnd.api+json',
        'Accept' => 'application/vnd.api+json',
        'Authorization' => "Bearer #{ API_KEY }",
      },
      body: {
        data: {
          attributes: {
            url: url,
          },
          type: 'purges',
        },
      }.to_json,
    }
  end

  def call
    purge = self.class.post('/purge', @options)
    purge.success?
  rescue Errno::ECONNRESET, Net::OpenTimeout, Errno::EHOSTUNREACH, SocketError, Net::ReadTimeout, EOFError, Errno::ECONNREFUSED
    { 'status' => 'failed' }
  end
end
