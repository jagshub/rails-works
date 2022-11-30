# frozen_string_literal: true

class Ships::Slack::Notification
  class << self
    def call(*)
      raise NotImplementedError, 'Must be implemented in a subclass'
    end
  end

  def deliver
    SlackNotify.call(
      channel: channel,
      username: username,
      icon_emoji: icon_emoji,
      attachment: {
        author_name: author_name,
        author_link: author_link,
        author_icon: author_icon,
        fallback: title,
        color: color,
        title: title,
        title_link: title_link,
        fields: fields,
      },
    )
  end

  private

  def channel
    raise NotImplementedError, 'Must be implemented in a subclass'
  end

  def author
    raise NotImplementedError, 'Must be implemented in a subclass'
  end

  def title
    raise NotImplementedError, 'Must be implemented in a subclass'
  end

  def title_link
    raise NotImplementedError, 'Must be implemented in a subclass'
  end

  def fields
    raise NotImplementedError, 'Must be implemented in a subclass'
  end

  def author_name
    "#{ author.name } (@#{ author.username })"
  end

  def author_link
    "https://www.producthunt.com/@#{ author.username }"
  end

  def author_icon
    Users::Avatar.url_for_user(author)
  end

  def username
    'Ship'
  end

  def icon_emoji
    ':boat:'
  end

  def color
    '#e6e6e6'
  end
end
