# frozen_string_literal: true

module Admin
  class DeleteUpcomingPageSubscribers < ApplicationJob
    def perform(upcoming_page)
      upcoming_page.subscribers.where(source_kind: 'import').destroy_all
    end
  end
end
