# frozen_string_literal: true

class Iterable::RemoveUserWorker < ApplicationJob
  include ActiveJobHandleNetworkErrors

  def perform(email:)
    External::IterableAPI.remove_user_from_iterable(email: email)
  end
end
