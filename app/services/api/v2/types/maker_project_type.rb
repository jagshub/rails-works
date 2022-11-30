# frozen_string_literal: true

module API::V2::Types
  class MakerProjectType < BaseObject
    description 'A maker project.'

    field :id, ID, 'ID of the MakerProject.', null: false
    field :url, String, 'URL of the MakerProject.', null: false
    field :name, String, 'ID of the MakerProject.', null: false
    field :tagline, String, 'Tagline of the MakerProject.', null: false
    field :looking_for_other_makers, Boolean, 'Whether the MakerProject owner is looking for other makers or not.', null: false
    field :image, String, 'Image of the MakerProject.', resolver: API::V2::Resolvers::ImageResolver.generate(null: true, &:image_uuid)

    def url
      Routes.root_url
    end
  end
end
