# frozen_string_literal: true

# TODO(DZ): Remove
module Posts::Jobs
  class EnrichVoters < ApplicationJob
    include ActiveJobHandleNetworkErrors

    def perform(post:, hard_refresh: false)
      post.votes.credible.includes(user: :subscriber).each do |vote|
        ClearbitProfiles.enrich_from_email(
          vote.user.email,
          refresh: hard_refresh,
          stream: true,
        )
      end
    end
  end
end
