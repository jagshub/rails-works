# frozen_string_literal: true

module Graph::Types
  class BannerType < BaseNode
    field :description, String, null: true
    field :url, String, null: false
    field :desktop_image_uuid, String, null: false
    field :wide_image_uuid, String, null: false
    field :tablet_image_uuid, String, null: false
    field :mobile_image_uuid, String, null: false
    field :dismissable, DismissType, null: true

    def dismissable
      return unless context[:current_user]

      DismissContent.dismissed(
        dismissable_key: object.id,
        dismissable_group: 'banner',
        user: context[:current_user],
        cookies: nil,
      )
    end
  end
end
