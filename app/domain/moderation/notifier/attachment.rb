# frozen_string_literal: true

class Moderation::Notifier::Attachment
  include Moderation::Notifier::UrlHelper

  attr_accessor :author, :reference, :message, :reason, :fields, :color

  # Note(LukasFittl): Interim fix to pass reason through, should be refactored.
  def initialize(author:, reference:, message:, reason: nil, fields: [], color: nil)
    @author    = author
    @reference = reference
    @message   = message
    @reason    = reason
    @fields    = fields
    @color     = convert_color color
  end

  def notify
    SlackNotify.call(
      text: url,
      username: author_name,
      icon_url: author_icon,
      attachment: to_h,
      channel: :admin_livefeed,
    )
  end

  def log
    ModerationLog.create! reference: reference, moderator: author, message: message, reason: reason
  end

  private

  def convert_color(color_name)
    case color_name
    when :red    then 'danger'
    when :yellow then 'warning'
    when :green  then 'good'
    end
  end

  def url
    url_for(reference)
  end

  def author_name
    "#{ author.name } (@ #{ author.username })" if author.present?
  end

  def author_icon
    Users::Avatar.url_for_user(author, size: 50) if author.present?
  end

  def to_h
    safe_message = ERB::Util.html_escape(message)

    {
      fallback: safe_message,
      author_name: author_name,
      author_link: url_for(author),
      author_icon: author_icon,
      text: message,
      color: color,
      fields: fields,
    }
  end
end
