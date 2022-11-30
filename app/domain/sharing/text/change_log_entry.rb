# frozen_string_literal: true

module Sharing::Text::ChangeLogEntry
  extend self

  def call(change)
    Twitter::Message
      .new
      .add_mandatory('Check out this update on @producthunt')
      .add_mandatory("\"#{ change.title }\"")
      .add_mandatory(Routes.change_log_url(change))
      .to_s
  end
end
