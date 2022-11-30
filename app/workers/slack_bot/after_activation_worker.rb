# frozen_string_literal: true

class SlackBot::AfterActivationWorker < ApplicationJob
  def perform(user)
    UpcomingPage.for_maintainers(user).each do |upcoming_page|
      UpcomingPages::MakerTasks.complete(upcoming_page)
    end

    Ships::Slack::NewSlackIntegration.call(user)
  end
end
