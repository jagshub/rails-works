# frozen_string_literal: true

class API::V2Internal::Resolvers::Collections::CollectionResolver < Graph::Resolvers::Base
  argument :id, ID, required: false
  argument :slug, String, required: false
  argument :username, String, required: false

  type API::V2Internal::Types::CollectionType, null: true

  def resolve(args = {})
    id = args[:id]
    slug = args[:slug]
    username = args[:username]

    if id.present?
      Collection.find_by(id: id)
    elsif username.present?
      find_by_username_and_slug(username, slug)
    else
      Collection.featured.find_by(slug: slug) || find_by_username_and_slug(Collection.default_curator_name, slug)
    end
  end

  private

  def find_by_username_and_slug(username, slug)
    Collection.published.joins(:user).merge(User.not_trashed).find_by(slug: slug, 'users.username' => username.downcase)
  end
end
