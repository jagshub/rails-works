# frozen_string_literal: true

class Screenshot
  def initialize(url)
    @url = url
  end

  def image_url(options = {})
    @image_url ||= generate_url query(options)
  end

  private

  def generate_url(options)
    return test_url(options) if Rails.env.test?

    query_string = options.sort.to_h.to_query
    token = Digest::MD5.hexdigest(query_string + Url2Png::API_SECRET)

    "https://url2png.producthunt.com/v6/#{ Url2Png::API_KEY }/#{ token }/png/?#{ query_string }"
  end

  # Note(andreasklinger): add default options here
  def query(options)
    {
      url: @url,
    }.reverse_merge options
  end

  def test_url(options)
    "http://placehold.it/#{ options[:width] || 850 }x#{ options[:height] || 850 }.png"
  end
end
