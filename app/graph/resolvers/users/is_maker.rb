# frozen_string_literal: true

class Graph::Resolvers::Users::IsMaker < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    Loader.for.load(object)
  end

  class Loader < GraphQL::Batch::Loader
    def perform(users)
      maker_ids = ProductMaker.of_visible_posts.where(user_id: users.pluck(:id)).pluck(Arel.sql('DISTINCT(product_makers.user_id)'))

      users.each do |user|
        fulfill user, maker_ids.include?(user.id)
      end
    end
  end
end
