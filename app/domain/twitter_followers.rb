# frozen_string_literal: true

# Note(TC): This is a generic service that allows us to track the twitter followers
# of mulitple subjects across our system. Each subject should have its own independent
# cooldown period
module TwitterFollowers
  extend self

  COOLDOWN = {
    Product: 2.weeks,
    User: 1.month,
  }.freeze

  def sync(subject:)
    TwitterFollowers::Sync.perform_later(subject: subject)
  end

  def refresh_worker
    TwitterFollowers::Refresh
  end
end
