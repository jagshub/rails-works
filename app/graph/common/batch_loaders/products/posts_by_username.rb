# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class Products::PostsByUsername < GraphQL::Batch::Loader
    def initialize(username)
      @username = username
    end

    def perform(products)
      user = User.find_by_username @username

      user_posts = Post.visible
                       .joins(:product_makers)
                       .where(product_makers: { user_id: user.id })

      product_posts = user_posts.joins(:product_association)
                                .includes(:product_association)
                                .where(product_association: { product_id: products.map(&:id) })
                                .order('posts.created_at DESC')
                                .group_by { |p| p.product_association.product_id }

      products.each do |product|
        fulfill product, product_posts.fetch(product.id, [])
      end
    end
  end
end
