# frozen_string_literal: true

# NOTE(DZ): Search association concern. Extend this into associations of
# searchable models.
#
module Search::SearchableAssociation
  extend self

  def define(model, association:, **configs)
    config = Config.new(associations: Array(association), **configs)

    model.class_eval do
      cattr_accessor :searchable_association_configs
      class_variable_set :@@searchable_association_configs, config

      after_save :reindex_searchable_associations, if: config.if
      # NOTE(DZ): Callback from destroy action must be done before destruction
      # as cascades may destroy relationship of associations. This may cause
      # de-sync with index if the destroy action is then aborted. Hopefully
      # this does not occur too often.
      before_destroy :reindex_searchable_associations

      model.extend ClassMethods
      model.include InstanceMethods
    end
  end

  module ClassMethods
    def searchable_association_reflections
      @searchable_association_reflections ||=
        searchable_association_configs.associations.map do |assoc|
          reflect_on_association(assoc)
        end
    end
  end

  module InstanceMethods
    # NOTE(DZ): Push association records into their own queues
    def reindex_searchable_associations
      return if Search.disable_indexing

      self.class.searchable_association_reflections.each do |reflection|
        # NOTE(DZ): Optimize case where this is has many assoc, just directly
        # push into index queue
        if reflection.macro == :has_many
          assoc_ids = public_send(reflection.name).ids
          next if assoc_ids.blank?

          if Search.environment_allows_indexing?
            assoc_ids.each do |assoc_id|
              reflection.klass.search_index.reindex_queue.push(assoc_id)
            end
          else
            Rails.logger.info(
              'Search::SearchableAssociation - Would enqueue'\
              " #{ reflection.klass } #{ assoc_ids }",
            )
          end
        else # belongs_to or has_one
          record = public_send(reflection.name)
          record.searchable_reindex if record.present?
        end
      end
    end
  end

  class Config
    attr_accessor :if, :associations

    def initialize(**configs)
      @if = configs[:if]
      @associations = Array(configs[:associations])
    end
  end
end
