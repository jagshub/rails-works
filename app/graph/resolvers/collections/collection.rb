# frozen_string_literal: true

class Graph::Resolvers::Collections::Collection < Graph::Resolvers::Base
  argument :id, ID, required: false
  argument :slug, String, ID, required: false
  argument :username, String, ID, required: false

  type Graph::Types::CollectionType, null: true

  def resolve(id: nil, slug: nil, username: nil)
    return Collection.visible(current_user).find_by(id: id) if id.present?
    return find_by_username_and_slug(username, slug) if username.present?

    Collection.featured.visible(current_user).find_by(slug: slug) ||
      find_by_username_and_slug(Collection.default_curator_name, slug)
  end

  private

  def find_by_username_and_slug(username, slug)
    Collection.published.visible(current_user).joins(:user).merge(User.not_trashed).find_by(slug: slug, 'users.username' => username.downcase)
  end
end
