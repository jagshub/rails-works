# frozen_string_literal: true

module MetaTags::MobileAppUrl
  extend self

  SCHEMA = 'producthunt://'

  PATHS = {
    'Collection' => 'collection',
    'Post' => 'post',
    'User' => 'user',
  }.freeze

  def perform(subject, params = {})
    # Note(andreasklinger): Comments do not have their own landing pages but are shown in other pages
    return perform(subject.subject, comment_id: subject.id) if subject.is_a?(Comment)

    class_name = subject.class.name
    path = PATHS[class_name]

    uri = if path.present?
            "#{ SCHEMA }#{ path }/#{ subject.id }"
          else
            "#{ SCHEMA }home"
          end

    uri += "?#{ params.to_query }" if params.any?

    uri
  end
end
