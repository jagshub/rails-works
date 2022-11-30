# frozen_string_literal: true

# Documentation
#
# - service: https://www.url2png.com
# - api: https://www.url2png.com/dashboard

module External::Url2pngApi
  extend self

  class InvalidSubject < StandardError; end

  STANDART_VIEWPORT = '1200x630'

  def share_url(subject, custom_action = '')
    width, height, checksum = options_for(subject)
    action = subject.class.name.downcase.split('::').join('_')
    if custom_action.present?
      action = custom_action
    end

    generate_url(
      url: "https://producthunt.com/shareable_image/#{ action }/#{ subject.id }",
      viewport: "#{ width }x#{ height }",
      say_cheese: true,
      ttl: 31_536_000,
      unique: Digest::MD5.hexdigest(checksum),
    )
  end

  private

  def generate_url(options)
    return generate_test_url(options) unless Rails.env.production?

    apikey = ENV['URL2PNG_KEY'] || ''
    secret = ENV['URL2PNG_SECRET'] || ''

    query = options.sort.map { |k, v| "#{ k }=#{ v }" }.join('&')
    token = Digest::MD5.hexdigest(query + secret)

    "https://api.url2png.com/v6/#{ apikey }/#{ token }/png/?#{ query }"
  end

  def generate_test_url(options)
    "http://placehold.it/#{ options[:viewport] || STANDART_VIEWPORT }.png"
  end

  def options_for(subject)
    case subject
    when Discussion::Thread
      [540, 270, "#{ subject.title }#{ subject.description }"]
    when ChangeLog::Entry
      [540, 270, subject.updated_at.to_s]
    when User
      [540, 270, subject.updated_at.to_s]
    when Comment
      [540, 270, subject.updated_at.to_s]
    when Job
      [540, 270, subject.updated_at.to_s]
    when Collection
      [540, 270, subject.updated_at.to_s]
    when Post
      [855, 920, subject.updated_at.to_s]
    when Products::Alternatives
      [540, 270, subject.product.updated_at.to_s]
    when Upcoming::Event
      [1200, 630, subject.updated_at.to_s]
    else
      raise InvalidSubject, "Given #{ subject.class.name }"
    end
  end
end
