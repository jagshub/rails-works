# frozen_string_literal: true

class Products::RefreshActivityEventsWorker < ApplicationJob
  include ActiveJobRetriesCount
  include ActiveJobHandleDeserializationError
  include ActiveJobHandlePostgresErrors

  def perform(product)
    Products::RefreshActivityEvents.new(product).call
  end
end
