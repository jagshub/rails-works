# frozen_string_literal: true

module ProductMakers::AcceptMakerSuggestion
  extend self

  def call(maker:)
    return unless maker.suggested?

    HandleRaceCondition.call do
      ActiveRecord::Base.transaction do
        other_accepted_suggestion = MakerSuggestion.where(maker_id: maker.user.id, post_id: maker.post.id).where.not(id: maker.suggestion.id).exists?

        if other_accepted_suggestion
          maker.suggestion.destroy!
        else
          maker.suggestion.update! maker_id: maker.user.id

          Iterable.trigger_event('new_maker', email: maker.user.email, user_id: maker.user.id)
          ProductMakers::CreateMaker.call(maker: maker)
        end
      end
    end
  end
end
