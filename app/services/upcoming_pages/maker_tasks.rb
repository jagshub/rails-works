# frozen_string_literal: true

module UpcomingPages::MakerTasks
  extend self

  TASKS = [
    UpcomingPages::MakerTasks::CreateUpcomingPage,
    UpcomingPages::MakerTasks::UploadLogo,
    UpcomingPages::MakerTasks::UploadSubscriberList,
    UpcomingPages::MakerTasks::AddImage,
    UpcomingPages::MakerTasks::AddSocialLinks,
    UpcomingPages::MakerTasks::UploadBackgroundImage,
    UpcomingPages::MakerTasks::AddSurvey,
    UpcomingPages::MakerTasks::InviteTeammates,
    UpcomingPages::MakerTasks::SendFirstMessage,
    UpcomingPages::MakerTasks::SlackIntegration,
    UpcomingPages::MakerTasks::EmbedUpcomingWidget,
  ].freeze

  def bootstrap(upcoming_page)
    create(upcoming_page)
    complete(upcoming_page)
  end

  def complete(upcoming_page)
    TASKS.each do |task|
      task.complete(upcoming_page)
    end
  end

  private

  def create(upcoming_page)
    TASKS.each do |task|
      task.create(upcoming_page)
    end
  end
end
