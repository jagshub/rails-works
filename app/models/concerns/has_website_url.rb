# frozen_string_literal: true

module HasWebsiteUrl
  extend self

  def define(model, column:, allow_blank:, schemes: %w(http https))
    column = column.to_sym

    model.before_validation do
      next if self[column].blank? && allow_blank

      uri = UrlCustomNormalizer.call(uri_str: self[column], schemes: schemes)
      if uri.blank?
        errors.add(column, 'is not a valid URL')
      else
        self[column] = uri
      end
    end
  end

  module UrlCustomNormalizer
    extend self

    # NOTE(emilov): normalize / clean up / fix the url a bit e.g.
    # HttP://exaMPLE.cOm/someSTUFF => http://example.com/someSTUFF
    # Prepend "http://" if missing, return nil if invalid. Do not allow
    # local urls or such that have no dots in them.
    def call(uri_str:, schemes: %w(http https))
      return uri_str if uri_str.blank?

      uri = Addressable::URI.heuristic_parse(uri_str.strip)
      uri.tld # NOTE(emilov): this raises exception if url is invalid
      uri.normalize! # NOTE(emilov): add missing http:// etc.

      if uri.host.present?
        uri.host.downcase!
        return if ['localhost', '127.0.0.1'].include?(uri.host)
      end

      if uri.scheme
        return unless schemes.include?(uri.scheme)
      end

      ret = uri.to_s
      return unless ret.include?('.')

      ret
    rescue  Addressable::URI::InvalidURIError, NoMethodError, URI::InvalidComponentError,
            PublicSuffix::DomainNotAllowed, PublicSuffix::DomainInvalid
      nil
    end
  end
end
