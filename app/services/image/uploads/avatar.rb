# frozen_string_literal: true

module Image::Uploads
  class Avatar < Image::Upload
    attr_reader :user

    class << self
      def call(source, user:, upload_key: nil)
        new(source, user: user, upload_key: upload_key).call
      end
    end

    def initialize(source, user:, upload_key:)
      @source = source
      @user = user
      @upload_key = upload_key
    end

    def call
      image_info = super

      # Note (Mike Coutermarsh): We set this because services/avatar.rb
      #   uses it to know if the avatar has been uploaded yet.
      #   Useful immediately after signup and before a user's image sync
      user.update!(avatar: avatar_key || key, avatar_uploaded_at: avatar_key ? Time.current : nil)

      image_info
    end

    private

    def meta_information(key)
      # Note (Mike Coutermarsh): Normally this method hits imgix to request information about the
      #   image (height/width). This is useful for things like image ratios in the image gallary.
      #   We don't need that information for Avatars though, so we skip making the call here.
      { image_uuid: key }
    end

    def s3_bucket
      :avatars
    end

    def key(_content_type = nil)
      # Note (Mike Coutermarsh): This is most important difference between this and the parent uploader
      #   Avatars must have a consistant file name. :user_id/original.
      @key ||= "#{ user.id }/original"
    end

    def avatar_key
      return unless @upload_key

      # Note (nvalchanov): We have to have a way to differentiate between manual avatar upload and avatar sync
      @avatar_key ||= "#{ user.id }/#{ @upload_key }"
    end
  end
end
