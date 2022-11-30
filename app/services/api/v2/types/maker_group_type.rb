# frozen_string_literal: true

module API::V2::Types
  class MakerGroupType < BaseObject
    description 'A group of makers, also known as Spaces on PH.'

    field :id, ID, 'ID of the MakerGroup.', null: false
    field :url, String, 'URL of the MakerGroup.', null: false
    field :name, String, 'Name of the MakerGroup.', null: false
    field :tagline, String, 'Tagline of the MakerGroup.', null: false
    field :description, String, 'Description of the MakerGroup.', null: false
    field :goals_count, Int, 'Number of goals that have been created in the MakerGroup.', null: false
    field :members_count, Int, 'Number of users who are part of the MakerGroup.', null: false

    field :is_member, Boolean, 'Whether Viewer is member of the MakerGroup or not.', resolver: API::V2::Resolvers::MakerGroups::IsMemberResolver, complexity: 2

    def url
      Routes.maker_group_url(object, url_tracking_params)
    end
  end
end
