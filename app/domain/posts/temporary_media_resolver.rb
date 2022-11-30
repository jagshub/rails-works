# frozen_string_literal: true

class Posts::TemporaryMediaResolver < Graph::Resolvers::Base
  ALLOWED_NAMES = %w(socialImageMedia thumbnail).freeze

  # NOTE(DZ): Temporary media resolver while migrating `thumbnail_image` and
  # `social_media_image`.
  def resolve(graphql_name:)
    check_graphql_name graphql_name

    if graphql_name == 'thumbnail'
      OpenStruct.new(
        # NOTE(DZ): Use post.id to simulate object id. Since each post can only
        # have one of each media type, this will help with apollo caching
        id: "Thumbnail-#{ object.id }",
        uuid: object.thumbnail_image_uuid,
        kind: :image,
        original_height: 300,
        original_width: 300,
        original_url: '',
        metadata: OpenStruct.new(
          url: nil,
          kindle_asin: nil,
          video_id: nil,
          platform: nil,
        ),
      )
    else
      OpenStruct.new(
        # NOTE(DZ): Use post.id to simulate object id. Since each post can only
        # have one of each media type, this will help with apollo caching
        id: "SocialMediaImage -#{ object.id }",
        uuid: object.social_media_image_uuid,
        kind: :image,
        original_height: 300,
        original_width: 300,
        original_url: '',
        metadata: OpenStruct.new(
          url: nil,
          kindle_asin: nil,
          video_id: nil,
          platform: nil,
        ),
      )
    end
  end

  private

  def check_graphql_name(graphql_name)
    return if ALLOWED_NAMES.include? graphql_name

    raise "Field #{ graphql_name } is not allowed for TemporaryMediaResolver"
  end
end
