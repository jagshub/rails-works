# frozen_string_literal: true

module AdsHelper
  def get_url(urlable, **params)
    valid = urlable.respond_to?(:url) && urlable.respond_to?(:url_params)
    raise "Invalid class #{ urlable.class }" unless valid

    uri = URI urlable.url
    query = Rack::Utils.parse_query uri.query
    query = query.merge(params.with_indifferent_access.compact)
    query = query.merge(urlable.url_params.with_indifferent_access)

    uri.query = query.to_query
    uri.to_s
  end
end
