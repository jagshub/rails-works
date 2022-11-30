# frozen_string_literal: true

class SpamChecks::SignIn::TrackSameBrowserWorker < ApplicationJob
  def perform(previous_user_id, current_user, request_info)
    previous_user = User.find previous_user_id

    Spam::MultipleAccountsLog.create! previous_user: previous_user, current_user: current_user, request_info: request_info
  end
end
