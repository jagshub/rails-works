# frozen_string_literal: true

class WebHooks::ClayWorker
  include Sidekiq::Worker

  def perform(payload = {})
    # NOTE(rstankov): We used this ages ago to create post drafts via Slack
  end
end
