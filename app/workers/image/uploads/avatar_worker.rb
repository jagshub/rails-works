# frozen_string_literal: true

class Image::Uploads::AvatarWorker < ApplicationJob
  def perform(source, user)
    Image::Uploads::Avatar.call(source, user: user)
    Users::Avatar.purge_cdn_for_user(user)
  rescue Image::Upload::FormatError
    # NOTE(rstankov): Fetching user avatar is not always possible
    nil
  end
end
