# frozen_string_literal: true

require 'redis/namespace'

class Spam::TwitterSuspensionReCheckWorker < ApplicationJob
  def perform(logged_after)
    Spam::Users::Checks::TwitterSuspension.check_false_positives logged_after: logged_after
  end
end
