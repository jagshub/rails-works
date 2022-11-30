# frozen_string_literal: true

module Notifications::Helpers::GetMentionedUserIds
  extend self

  def for_text(text)
    mentions = text.scan(/@([a-zA-Z0-9_]*)/).map(&:first)
    # Note(andreasklinger): Using `.pluck` caused weird results.
    #   Anyhow the results should never not be big enough for non-lazy map.
    User.by_usernames(mentions).map(&:id)
  end
end
