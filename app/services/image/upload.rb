# frozen_string_literal: true

module Image
  class Upload
    attr_reader :source

    S3_ACCESS_KEY = ENV.fetch('AWS_FILES_UPLOAD_ACCESS_KEY_ID')
    S3_SECRET_KEY = ENV.fetch('AWS_FILES_UPLOAD_SECRET_ACCESS_KEY')

    class << self
      def call(source)
        new(source).call
      end
    end

    def initialize(source)
      @source = source
    end

    def call
      body, content_type = if data_uri?
                             parse_data_uri
                           elsif url?
                             fetch_url
                           elsif file?
                             load_file
                           else
                             raise Image::Upload::FormatError, 'Neither url (String) nor file (Tempfile) nor data URI (String) provided'
                           end

      raise Image::Upload::FormatError, 'Provided upload source is not an image' unless valid_body?(body) && image?(content_type)

      key = s3_upload(body, content_type)

      meta_information(key)
    end

    private

    def s3_bucket
      :images
    end

    def fetch_url
      return [] if source.nil?
      return [] unless Image::UrlValidator.allow?(source)

      response = HTTParty.get(source)
      [response.body, response.headers['content-type']]
    rescue Errno::EINVAL, OpenSSL::SSL::SSLError, SocketError, URI::InvalidURIError, Errno::ECONNREFUSED, HTTParty::UnsupportedURIScheme, Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET, Errno::EADDRNOTAVAIL, ArgumentError, Zlib::DataError
      []
    end

    def load_file
      [source.read, MimeTypesByExtension.get(filename)]
    end

    def parse_data_uri
      uri = URI::Data.new(source)
      [uri.data, uri.content_type]
    rescue URI::InvalidURIError
      []
    end

    def filename
      source.respond_to?(:original_filename) ? source.original_filename : source.path
    end

    def s3_upload(body, content_type)
      External::S3Api.put_object(
        bucket: s3_bucket,
        key: @upload_key ? avatar_key : key(content_type),
        body: body,
        content_type: content_type,
      )
    end

    def key(content_type)
      extension = ::Image::FileExtension.call content_type

      @key ||= "#{ External::S3Api.generate_key }.#{ extension }"
    end

    def meta_information(key)
      response = HTTParty.get Image.call(key, format: :json)
      meta = response.respond_to?(:to_h) ? response.to_h : {}

      {
        image_uuid: key,
        original_width: meta['PixelWidth'],
        original_height: meta['PixelHeight'],
      }
    rescue Net::ReadTimeout, Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EADDRNOTAVAIL, Net::OpenTimeout, EOFError, SocketError
      {
        image_uuid: key,
        original_width: nil,
        original_height: nil,
      }
    end

    def file?
      source.is_a?(ActionDispatch::Http::UploadedFile) || source.is_a?(File) || source.is_a?(Tempfile)
    end

    def url?
      source.is_a?(String) && source =~ URI::DEFAULT_PARSER.make_regexp
    end

    def data_uri?
      source.is_a?(String) && source.match(/^data:/).present?
    end

    def valid_body?(body)
      body.present?
    rescue ArgumentError
      false
    end

    def image?(content_type)
      return false if content_type.blank?

      # Note(andreasklinger): Some hosters send default mimetype octet stream for images if misconfigured.
      content_type.start_with?('image/') || content_type == 'application/octet-stream'
    end

    class FormatError < StandardError; end
  end
end
