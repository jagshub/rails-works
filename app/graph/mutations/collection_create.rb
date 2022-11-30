# frozen_string_literal: true

module Graph::Mutations
  class CollectionCreate < BaseMutation
    argument :name, String, required: true
    argument_record :post, Post

    returns Graph::Types::CollectionType

    require_current_user

    def perform(name:, post:)
      collection = HandleRaceCondition.call { current_user.collections.create(name: name&.strip) }

      return errors_from_record collection if collection.errors.any?

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
