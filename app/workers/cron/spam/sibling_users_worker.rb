# frozen_string_literal: true

class Cron::Spam::SiblingUsersWorker < ApplicationJob
  def perform
    now = Time.zone.now
    Spam::Posts.run_sibling_users_check now
    Spam::Posts.run_sibling_users_check(now - 2.5.minutes)
    Spam::Posts.run_sibling_users_check(now - 5.minutes)
    Spam::Posts.run_sibling_users_check(now - 7.5.minutes)
  end
end
