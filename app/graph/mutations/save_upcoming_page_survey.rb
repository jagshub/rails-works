# frozen_string_literal: true

module Graph::Mutations
  class SaveUpcomingPageSurvey < BaseMutation
    argument :id, ID, required: false
    argument :upcoming_page_id, ID, required: false
    argument :title, String, required: false
    argument :description, Graph::Types::HTMLType, required: false
    argument :closed_at, Graph::Types::DateType, required: false

    argument :success_text, Graph::Types::HTMLType, required: false
    argument :welcome_text, Graph::Types::HTMLType, required: false

    argument :background_image_uuid, String, required: false
    argument :background_color, String, required: false

    argument :button_color, String, required: false
    argument :button_text_color, String, required: false
    argument :link_color, String, required: false
    argument :title_color, String, required: false

    argument :status, String, required: false

    returns Graph::Types::UpcomingPageSurveyType

    def perform(inputs)
      survey = find_or_create_survey(inputs[:id], inputs[:upcoming_page_id])

      form = ::UpcomingPages::Surveys::Form.new(survey: survey, user: current_user)
      form.update inputs
      form
    end

    private

    def find_or_create_survey(upcoming_page_survey_id, upcoming_page_id)
      if upcoming_page_survey_id.present?
        UpcomingPageSurvey.find(upcoming_page_survey_id)
      else
        upcoming_page = UpcomingPage.find(upcoming_page_id)
        UpcomingPageSurvey.new(upcoming_page: upcoming_page)
      end
    end
  end
end
