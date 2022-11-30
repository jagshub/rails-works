# frozen_string_literal: true

module UsersHelper
  def user_image(user, badge: '', size:, **opts)
    html_class = ['user-image', opts.delete(:class)]
    html_class << 'v-big' if size >= 100
    html_class = html_class.compact.join(' ')

    image_url = Users::Avatar.url_for_user(user, size: (size * 2))

    content_tag :span, class: html_class do
      badge.html_safe + twitter_image_tag(image_url, size: size, **opts.except(:schema))
    end
  end

  def link_to_user(user, url_options = {}, size: 30, **opts)
    image = user_image user, alt: user.name, title: user.name,
                             size: size, schema: 'https'

    link_to image, profile_url(user.username, url_options), { target: '_blank' }.merge(opts)
  end

  private

  BLANK_IMAGE = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='

  def twitter_image_tag(image_url, size:, **opts)
    if image_url[/pbs.twimg.com/] && size > 80
      # Twitter returns square images for all variants except the original.
      # Use alternative background-image based approach to get a square image.
      opts[:class] += ' user-image-as-background'
      opts[:style] = format('background-image: url(%s); width: %dpx; height: %dpx',
                            image_url, size, size)
      tag 'span', opts
    else
      opts[:size] = size.to_s

      image_tag image_url, opts
    end
  end
end
