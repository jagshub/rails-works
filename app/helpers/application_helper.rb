# frozen_string_literal: true

module ApplicationHelper
  def helper_classes
    # Note(andreasklinger): The `controllername-actionname` css helpers are legacy.
    #   Please do no longer use them but apply explicit css classes to elements where needed.

    classes = []
    classes << "#{ controller_path.tr('/', '-') }-#{ action_name }"
    classes << 'env-' + Rails.env unless Rails.env.production?
    classes.join ' '
  end

  def better_format(text, mode:)
    raw BetterFormatter.call(text, mode: mode)
  end

  def jquery_javascript_tag
    javascript_include_tag("#{ request.base_url }/jquery-3.6.0.min.js") + javascript_include_tag("#{ request.base_url }/jquery-ujs-1.2.3-rails.js")
  end
end
