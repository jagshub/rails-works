# frozen_string_literal: true

# NOTE(DZ): Search implementation using Searchkick and Elastic cloud.
#
module Search::Searchable
  extend self

  # NOTE(DZ): Track which models are using extension.
  attr_accessor :models
  @models = []

  # NOTE(DZ): For spec purposes
  def add_searchable_model(model)
    @models << model
  end

  def define(model, **configs)
    add_searchable_model model
    config = Config.new(model, configs)

    model.class_eval do
      searchkick config.searchkick_configs

      cattr_accessor :searchable_config
      class_variable_set :@@searchable_config, config

      after_save :searchable_reindex, if: config.if
      after_destroy :searchable_reindex

      model.extend ClassMethods
      model.include InstanceMethods

      def search_data
        raise "Missing definition of #searchable_data in #{ self.class }" unless
          respond_to?(:searchable_data)

        searchable_data.to_h
      end
    end
  end

  module ClassMethods
    # NOTE(DZ): Specify scope of indexable records. Name 'search_import' is used
    # by searchkick
    def search_import
      public_send(searchable_config.only).includes(searchable_config.includes)
    end
  end

  module InstanceMethods
    def searchable_reindex
      return if Search.disable_indexing

      if Search.environment_allows_indexing?
        # NOTE(DZ): We plug into searchkick queues which uses redis
        # https://github.com/ankane/searchkick#queuing
        self.class.search_index.reindex_queue.push(id.to_s)
      else
        Rails.logger.info(
          "Search::Searchable - Would enqueue #{ self.class.name } #{ id }",
        )
      end
    end
  end

  class Config
    attr_accessor :searchkick_configs, :searchable_configs

    SEARCHABLE_OPTIONS = %i(only includes if).freeze

    def initialize(model, **configs)
      @searchkick_configs = configs.except(*SEARCHABLE_OPTIONS).merge(
        callbacks: false,
        index_name: index_name(model),
        special_characters: false,
      )
      @searchable_configs = configs.slice(*SEARCHABLE_OPTIONS)
    end

    def includes
      Array(searchable_configs[:includes]) || []
    end

    def only
      searchable_configs[:only] || :all
    end

    def if
      searchable_configs[:if]
    end

    # NOTE(DZ): For searchkick indices, we overwrite the default pattern to
    # point staging at production.
    def index_name(model)
      env = Rails.env.staging? ? 'production' : Rails.env
      [model.model_name.plural, env].compact.join('_')
    end
  end
end
