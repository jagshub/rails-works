# frozen_string_literal: true

class UpcomingPages::Surveys::Form
  include MiniForm::Model

  ATTRIBUTES = %i(
    title
    description
    success_text
    welcome_text
    background_image_uuid
    background_color
    button_color
    button_text_color
    link_color
    title_color
    status
    upcoming_page_id
    closed_at
  ).freeze

  model :survey, attributes: ATTRIBUTES, read: %i(id), save: true

  before_update :authorize_save
  after_update :complete_tasks

  alias node survey
  alias graphql_result survey

  def initialize(survey:, user: nil)
    @user = user
    @survey = survey
  end

  private

  def authorize_save
    ApplicationPolicy.authorize! @user, ApplicationPolicy::MAINTAIN, @survey
  end

  def complete_tasks
    UpcomingPages::MakerTasks::AddSurvey.complete(node.upcoming_page)
  end
end
