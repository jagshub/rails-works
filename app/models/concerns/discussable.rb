# frozen_string_literal: true

module Discussable
  extend ActiveSupport::Concern

  included do
    include ExplicitCounterCache

    has_many :discussions, class_name: '::Discussion::Thread', as: :subject, inverse_of: :subject, dependent: :destroy

    explicit_counter_cache :discussions_count, -> { discussions.where(trashed_at: nil) }
  end
end
