# frozen_string_literal: true

class BaseSerializer
  include Rewired::Serializer
  include UsersHelper
  include Routes

  class_attribute :root

  attr_accessor :resource, :scope

  class << self
    def resource(resource, scope = {}, options = {})
      serializer = new(resource, scope)

      root_name = root_name_for(:singular, resource, options)

      if root_name.present?
        { root_name => serializer }
      else
        serializer
      end
    end

    def collection(collection, scope = {}, options = {})
      serializer = collection.map { |resource| new(resource, scope) }

      root_name = root_name_for(:plural, collection, options)

      if root_name.present?
        { root_name => serializer }
      else
        serializer
      end
    end

    def cache_resource(resource, scope = {})
      serializer = self.resource(resource, scope)

      json = Rails.cache.fetch build_serializer_cache_key(serializer) do
        Rewired.json_dump(serializer)
      end

      Rewired::Identity.new(json)
    end

    def cache_collection(collection, scope = {})
      serializers = self.collection(collection, scope)

      serializer_cache_map = build_serializer_cache_map(serializers)

      # Multi-fetch all cache keys
      rendered_serializer_map = Rails.cache.fetch_multi(*serializer_cache_map.keys) do |key|
        Rewired.json_dump(serializer_cache_map[key])
      end

      # Merge the rendered hash back with the original hash for order. Return rendered values.
      rendered_serializers = serializer_cache_map.merge(rendered_serializer_map).values

      # Wrap all rendered JSON values to prevent double-escaping.
      rendered_serializers.map { |rendered_serializer| Rewired::Identity.new(rendered_serializer) }
    end

    private

    def root_name_for(kind, resource, options = {})
      return options[:root] if options.key?(:root)
      return if root == false
      return unless resource.respond_to?(:model_name)

      resource.model_name.public_send(kind)
    end

    def build_serializer_cache_key(serializer)
      ActiveSupport::Cache.expand_cache_key [::API::V1::SerializerCache.serializer_checksum, serializer.class.name, serializer.cache_key, serializer.scope].flatten
    end

    def build_serializer_cache_map(serializers)
      cache_key_serializer_pairs = serializers.map { |serializer| [build_serializer_cache_key(serializer), serializer] }

      ActiveSupport::OrderedHash[cache_key_serializer_pairs]
    end
  end

  def initialize(resource, scope = {})
    @resource = resource
    @scope = scope
  end
end
