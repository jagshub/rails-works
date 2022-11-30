# frozen_string_literal: true

# Camo = an SSL proxy that enables us to serve non-ssl images and audio over ssl

# Note(Mike Coutermarsh): We use this proxy for anything we do not want to store on S3.
#   Images in comments and podcast audio files are good examples of media we want to proxy.
#
#   We don't use the Files service because we do not want to be an image host for every random link placed in a comment.

require 'openssl'

module External::CamoApi
  CAMO_KEY = ENV.fetch('CAMO_KEY')
  CAMO_HOST = ENV.fetch('CAMO_HOST')

  def self.url(media_url)
    return if media_url.blank?
    return media_url if media_url =~ /^https/

    hexdigest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), CAMO_KEY, media_url)
    encoded_media_url = media_url.to_enum(:each_byte).map { |byte| format('%02x', byte) }.join
    "#{ CAMO_HOST }/#{ hexdigest }/#{ encoded_media_url }"
  end
end
