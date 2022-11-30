# frozen_string_literal: true

module MetaTags
  def meta_tags(tags = {})
    @meta_tags ||= {}
    @meta_tags.merge! tags
  end

  def page_title(title = nil, append: nil)
    return if request.xhr?

    @meta_tags ||= {}
    @meta_tags[:title] = title if title.present?
    @meta_tags[:title] += " | #{ append }" if append.present?
  end
end
