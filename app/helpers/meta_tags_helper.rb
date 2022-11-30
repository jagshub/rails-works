# frozen_string_literal: true

module MetaTagsHelper
  def render_meta_tags(meta_tags = {})
    MetaTags::Renderer.call(url: request.original_url, meta_tags: meta_tags || {})
  end
end
