# frozen_string_literal: true

class Search::Workers::IndexCronWorker < ApplicationJob
  queue_as :search_export

  def perform
    # NOTE(DZ): Sync job only should be run in production
    if Search.environment_allows_indexing?
      Search::Searchable.models.each do |model|
        Searchkick::ProcessQueueJob.perform_later(class_name: model.name)
      end
    else
      Rails.logger.info(
        'Search::Workers::IndexCronWorker - Would perform',
      )
    end
  end
end
