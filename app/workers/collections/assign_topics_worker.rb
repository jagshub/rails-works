# frozen_string_literal: true

class Collections::AssignTopicsWorker < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(collection)
    HandleRaceCondition.call do
      collection.topics = Collections::RelatedTopics.call(collection, limit: 5)
    end
  rescue ActiveRecord::RecordInvalid
    # NOTE(rstankov): Topics already assigned
    nil
  end
end
