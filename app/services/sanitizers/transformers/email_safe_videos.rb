# frozen_string_literal: true

module Sanitizers::Transformers::EmailSafeVideos
  extend self

  def call(node:, node_name:, **)
    return unless node_name == 'template'
    return unless node.attributes['type']&.value == 'video'

    video_id = node.attributes['video-id']&.value

    href = "https://www.youtube.com/watch?v=#{ video_id }"
    thumbnail = "https://img.youtube.com/vi/#{ video_id }/hqdefault.jpg"

    html_str = <<~HTML.strip
      <div>
        <a href="#{ href }" target="_blank" rel="nofollow noopener noreferrer">
          <img src="#{ thumbnail }">
        </a>
      </div>
    HTML

    node.replace(Nokogiri::HTML.fragment(html_str).children[0])
  end
end
