# frozen_string_literal: true

module Mobile::Graph::Mutations
  class CollectionCreate < BaseMutation
    argument :name, String, required: true
    argument_record :post, Post, required: false

    returns Mobile::Graph::Types::CollectionType

    require_current_user

    def perform(name:, post: nil)
      collection = HandleRaceCondition.call { current_user.collections.create!(name: name&.strip) }

      return collection if post.nil?

      collection_post = Collections.add(collection, post)[:post_association]

      if collection_post.errors.empty?
        success collection
      else
        errors_from_record collection_post
      end
    end

    def errors_from_record(record)
      { errors: Error.from_record(record) }
    end
  end
end
