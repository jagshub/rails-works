# frozen_string_literal: true

module Graph::Types
  class MakersFestival::ParticipantType < BaseNode
    implements Graph::Types::VotableInterfaceType

    graphql_name 'MakersFestivalParticipant'

    field :makers_festival_category, Graph::Types::MakersFestival::CategoryType, null: false
    field :external_link, String, null: true
    field :user, Graph::Types::UserType, null: false
    field :makers, [Graph::Types::UserType], null: false
    field :snapchat_app_id, String, null: true
    field :snapchat_app_video_link, String, null: true
    field :snapchat_username, String, null: true
    field :project_name, String, null: true
    field :project_tagline, String, null: true
    field :project_thumbnail, String, null: true
    field :submission_completed, Boolean, null: false
    field :receive_tc_resources, Boolean, null: false

    def submission_completed
      object.project_name.present? && object.project_tagline.present? && object.project_thumbnail.present? && object.external_link.present?
    end
  end
end
