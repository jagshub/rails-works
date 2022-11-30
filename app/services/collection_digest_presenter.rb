# frozen_string_literal: true

class CollectionDigestPresenter
  include ActionView::Helpers::TextHelper

  CURATOR_LIMIT = 3

  def initialize(collections)
    @collections = collections
  end

  def subject
    if collections.size == 1
      collection = collections.first
      post_names = collection.recently_added_posts.map(&:name)

      posts = if post_names.size == 1
                post_names.first
              else
                "#{ post_names.first } and #{ post_names.size - 1 } more"
              end

      "#{ collection.user.name } added #{ posts } to #{ collection.name }"
    else
      "#{ curator_names(2) } updated collections you follow"
    end
  end

  def curators
    @curators ||= @collections.map(&:user).uniq
  end

  def curator_names(limit = CURATOR_LIMIT)
    curator_sentence = curators.map(&:name).take(limit)
    curator_sentence << pluralize(curators.size - limit, 'other').to_s if curators.size > limit
    curator_sentence.to_sentence
  end

  def curator_avatar_urls
    curators.map do |curator|
      Users::Avatar.url_for_user(curator, size: 40)
    end
  end

  def collections
    @decorated_collections ||= @collections.map do |collection|
      CollectionDigestPresenter::CollectionDecorator.new(collection)
    end
  end
end
