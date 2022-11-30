# frozen_string_literal: true

module Users
  module Avatar
    extend self

    BASE_URL = 'https://ph-avatars.imgix.net'
    DEFAULT_SIZE = 30
    DEFAULT_AVATAR = 'https://ph-static.imgix.net/guest-user-avatar.png?auto=format&auto=compress'

    def url_for_user(user, size: DEFAULT_SIZE)
      raise ArgumentError unless size.is_a?(Integer) || size == 'original'

      cdn_url = cdn_url_for_user(user)

      return "#{ cdn_url }?auto=format&fit=crop&crop=faces&w=#{ size }&h=#{ size }" if cdn_url

      DEFAULT_AVATAR
    end

    def refresh_for_user(user)
      Image::Uploads::Avatar.call(user.image, user: user)

      purge_cdn_for_user(user)
    rescue Image::Upload::FormatError
      nil
    end

    def purge_cdn_for_user(user)
      Cdn::PurgeCache.call url_for_user(user)
    end

    # Note (Mike Coutermarsh): These are no longer used, kept here for API compatibility
    LEGACY_SIZES = [30, 32, 40, 44, 48, 50, 60, 64, 73, 80, 88, 96, 100, 110, 120, 132, 146, 160, 176, 220, 264].freeze

    def cdn_url_for_user(user)
      url = user.avatar&.ends_with?('original') ? "#{ user.id }/original" : user.avatar

      "#{ BASE_URL }/#{ url }" if url
    end
  end
end
