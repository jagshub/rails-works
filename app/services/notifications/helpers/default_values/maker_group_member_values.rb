# frozen_string_literal: true

class Notifications::Helpers::DefaultValues::MakerGroupMemberValues < Notifications::Helpers::DefaultValues::BaseValues
  IMAGE_UUID = '76fab23b-214a-4472-bce6-72dc2a35abee'
  SIZE = 256

  # NOTE(ayrton)(maker-goals) replace me with group avatar
  def thumbnail_url
    Image.call(IMAGE_UUID, height: SIZE, width: SIZE)
  end

  def weblink_url
    return Routes.makers_url if object.group.main?

    Routes.maker_group_url(object.group)
  end
end
