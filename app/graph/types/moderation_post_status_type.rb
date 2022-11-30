# frozen_string_literal: true

module Graph::Types
  class ModerationPostStatusType < BaseObject
    field :id, ID, null: false

    field :state, String, null: false

    field :score_multiplier, Float, null: true
    field :needs_moderation, Boolean, null: false, method: :needs_moderation?
    field :media_count, Int, null: false

    def media_count
      object.media.size
    end

    field :is_featured, Boolean, null: false, method: :featured_at?
    field :maker_count, Int, null: false

    def maker_count
      object.makers.size
    end

    field :maker_suggestion_count, Int, null: false

    def maker_suggestion_count
      object.maker_suggestions.size
    end

    field :associated_products_count, Int, null: false

    def associated_products_count
      object.new_product&.associated_products_count || 0
    end

    field :has_description, Boolean, null: false

    def has_description
      object.description_length > 0
    end

    field :non_credible_votes_percent, Float, null: false

    def non_credible_votes_percent
      return 0 if object.votes_count == 0

      (object.votes_count - object.credible_votes_count) *
        100.0 / object.votes_count
    end

    field :sandboxed_votes_count, Integer, null: false

    def sandboxed_votes_count
      object.votes.where(sandboxed: true).count
    end

    field :votes_count, Int, null: false
    field :credible_votes_count, Int, null: false
    field :daily_rank, Int, null: true
    field :weekly_rank, Int, null: true
    field :monthly_rank, Int, null: true
  end
end
