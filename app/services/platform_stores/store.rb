# frozen_string_literal: true

module PlatformStores
  class Store
    class << self
      def new(options)
        klass = Class.new(self)
        klass.const_set(:ENUM, options.fetch(:enum))
        klass.const_set(:NAME, options.fetch(:name))
        klass.const_set(:MATCHERS, options.fetch(:matchers))
        klass.const_set(:KEY, options.fetch(:key))
        klass.const_set(:OS, options.fetch(:os))
        klass
      end

      def matchers
        self::MATCHERS
      end

      def name
        self::NAME
      end

      def enum
        self::ENUM
      end

      def key
        self::KEY
      end

      def os
        self::OS
      end

      def key?(other_key)
        return false unless other_key

        other_key.to_sym == key
      end

      def match_url(url)
        url = url.gsub(%r{^https://www\.google\.com/url\?q=}, '')
        url = url.gsub(%r{^https?://}, '')
        url = url.gsub(/^www\./, '')

        matchers.each do |regexp|
          match = url[regexp]
          return match if match
        end

        nil
      end
    end
  end
end
