# frozen_string_literal: true

require 'digest/sha1'

class API::V1::SerializerCache
  class << self
    def fetch(serializer_klass, resource_or_collection, serialization_scope, options = {}, &block)
      HandleRedisErrors.call(fallback: block) do
        # Note(andreasklinger): to avoid expensive memcache roundtrips we only cache the full response
        #   if it has no current_user context
        return block.call if serialization_scope[:current_user].present?

        method = resource_or_collection.respond_to?(:map) ? 'collection' : 'resource'
        cache_key = ActiveSupport::Cache.expand_cache_key([serializer_checksum, method, resource_or_collection, serialization_scope, serializer_klass, options])
        Rails.cache.fetch cache_key, &block
      end
    end

    def serializer_checksum
      return @serializer_checksum if @serializer_checksum.present? && !Rails.env.development?

      digest = Digest::SHA1.new
      serializer_files.each { |f| digest.file(f) }
      @serializer_checksum = digest.hexdigest
    end

    private

    def serializer_files
      Dir.glob(Rails.root.join('app', 'serializers', '**', '*.rb'))
    end
  end
end
