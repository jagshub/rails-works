# frozen_string_literal: true

module ProductMakers::ApproveMakerSuggestion
  extend self

  def call(approved_by:, maker:)
    return false unless maker.suggested?

    maker.suggestion.update! approved_by_id: approved_by.id

    ProductMakers::CreateMaker.call(maker: maker) if maker.joined?
    ProductMakers::SendTweetWorker.set(wait_until: maker.post.date).perform_later(maker.username, maker.post)
  end
end
