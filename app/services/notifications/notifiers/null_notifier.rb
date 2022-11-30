# frozen_string_literal: true

# NOTE(rstankov): Used as placeholder for removed notifiers
module Notifications::Notifiers::NullNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {}
  end

  def subscriber_ids(_object)
    []
  end
end
