# frozen_string_literal: true

module Posts::EmbedBadgeMessage
  extend self

  def call(post, ctx)
    return unless visible?(post, ctx)

    type = get_type post

    return if type.blank?

    url = Routes.embed_post_path(post.slug)

    variants = {
      default: OpenStruct.new(
        title: 'Embed a badge',
        tagline: 'Let visitors know you have launched',
        url: url,
      ),
      featured: OpenStruct.new(
        title: 'Embed a badge',
        tagline: "Let visitors know you're featured",
        url: url,
      ),
      top_post: OpenStruct.new(
        title: 'Embed a badge to your website',
        tagline: "Let visitors know you're Product of the Day",
        url: url,
      ),
    }

    variants[type]
  end

  private

  def product_maker?(user, post)
    ProductMaker.find_by(user_id: user.id, post_id: post.id).present?
  end

  def visible?(post, ctx)
    return false if ctx[:current_user].blank?
    return false unless product_maker?(ctx[:current_user], post)

    true
  end

  def get_type(post)
    if Badges::TopPostBadge.where(subject: post).any?
      type = :top_post unless TrackingPixel.tracked?(post, :top_post_badge)

      return type
    end

    if post.featured?
      type = :featured unless TrackingPixel.tracked?(post, :featured_post_badge)

      return type
    end

    return :default unless TrackingPixel.tracked?(post, :default_post_badge)
  end
end
