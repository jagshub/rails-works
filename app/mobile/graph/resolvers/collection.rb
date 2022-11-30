# frozen_string_literal: true

class Mobile::Graph::Resolvers::Collection < Mobile::Graph::Resolvers::BaseResolver
  argument :id, ID, required: true
  argument :username, String, ID, required: false

  type Mobile::Graph::Types::CollectionType, null: true

  def resolve(id:, username: nil)
    return find_by_username_and_id(username, id) if username.present?

    find_by_id_or_featured_collection(id)
  end

  private

  def find_by_id_or_featured_collection(id)
    Collection.visible(current_user).friendly.find(id)
  rescue ActiveRecord::RecordNotFound
    find_by_username_and_id(Collection.default_curator_name, id)
  end

  def find_by_username_and_id(username, id)
    Collection.published.visible(current_user).joins(:user).merge(User.not_trashed).where('users.username' => username.downcase).friendly.find(id)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
