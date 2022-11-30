# frozen_string_literal: true

require 'rexml/document'

module LinkSpect::Awis
  extend self

  AWS_API_URL = 'https://awis.amazonaws.com/api'

  def blocked?(urls)
    urls.each_slice(5).each do |batch|
      block = ::LinkSpect::Response.blocked?(batch_call(batch), 'awis', true)

      return true if block
    end

    false
  end

  private

  def batch_call(urls)
    tomorrow = Time.zone.tomorrow

    url_params = urls.map.with_index { |url, i| ["UrlInfo.#{ i + 1 }.Url", escape_url(url, /[^A-Za-z0-9\-_.~]/)] }

    query = ({
      Action: 'UrlInfo',
      ResponseGroup: 'AdultContent',
    }.to_a + url_params).to_h

    resp = HTTParty.get(
      "#{ AWS_API_URL }?#{ query.to_query }",
      headers: get_header(query),
    )

    result = resp&.response&.body
    return [] if result.blank?

    xml = REXML::Document.new(result)
    result = REXML::XPath.match(xml, '//aws:AdultContent')

    urls.map.with_index do |url, i|
      ::LinkSpect::Response::Log.new(
        blocked: result[i]&.text == 'yes',
        external_link: url,
        source: 'awis',
        expires_at: tomorrow,
      )
    end
  end

  def get_header(query)
    timestamp = Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
    datestamp = Time.now.utc.strftime('%Y%m%d')

    {
      'Content-Type': 'application/xml',
      'host': 'awis.us-west-1.amazonaws.com',
      'x-amz-date': timestamp,
      'Accept': 'application/xml',
      'Authorization': awis_auth(query.to_query, timestamp, datestamp),
    }
  end

  def get_signature_key(key, date_stamp, region_name, service_name)
    k_date    = OpenSSL::HMAC.digest('sha256', 'AWS4' + key, date_stamp)
    k_region  = OpenSSL::HMAC.digest('sha256', k_date, region_name)
    k_service = OpenSSL::HMAC.digest('sha256', k_region, service_name)

    OpenSSL::HMAC.digest('sha256', k_service, 'aws4_request')
  end

  def awis_auth(query_str, timestamp, datestamp)
    algorithm = 'AWS4-HMAC-SHA256'
    credential_scope = "#{ datestamp }/us-west-1/awis/aws4_request"
    payload_hash = Digest::SHA256.hexdigest ''
    canonical_request = "GET\n/api\n#{ query_str }\nhost:awis.us-west-1.amazonaws.com\nx-amz-date:#{ timestamp }\n\nhost;x-amz-date\n#{ payload_hash }"
    string_to_sign = algorithm + "\n" + timestamp + "\n" + credential_scope + "\n" + (Digest::SHA256.hexdigest canonical_request)
    signing_key = get_signature_key(ENV['AWIS_SECRET_KEY'], datestamp, 'us-west-1', 'awis')
    signature = OpenSSL::HMAC.hexdigest('sha256', signing_key, string_to_sign)

    "#{ algorithm } Credential=#{ ENV['AWIS_ACCESS_KEY'] }/#{ credential_scope }, SignedHeaders=host;x-amz-date, Signature=#{ signature }"
  end

  # NOTE(rstankov): Taken from
  #  - https://ruby-doc.org/stdlib-2.5.1/libdoc/uri/rdoc/URI/RFC2396_Parser.html#method-i-escape
  def escape_url(str, unsafe)
    unless unsafe.is_a?(Regexp)
      # perhaps unsafe is String object
      unsafe = Regexp.new("[#{ Regexp.quote(unsafe) }]", false)
    end
    str.gsub(unsafe) do
      us = $&
      tmp = ''
      us.each_byte do |uc|
        tmp += format('%%%02X', uc)
      end
      tmp
    end.force_encoding(Encoding::US_ASCII)
  end
end
