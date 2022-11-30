module Types
  class PreloadableField < Types::BaseField
    def initialize(*args, preload: nil, **kwargs, &block)
      @preloads = preload
      Rails.logger.info "PreloadableField!!"
      super(*args, **kwargs, &block)
    end

    def resolve(type, args, ctx)
      return super unless @preloads

      BatchLoader::GraphQL.for(type).batch(key: self) do |records, loader|
        ActiveRecord::Associations::Preloader.new.preload(records.map(&:object), @preloads)
        records.each { |r| loader.call(r, super(r, args, ctx)) }
      end
    end
  end
end
