# frozen_string_literal: true

module Collections
  extend self

  def add(collection, object)
    HandleRaceCondition.call do
      raise 'Either post or product are required' if object.nil?

      post, product = post_and_product_by_object_type(object)

      post_assoc = collection.collection_post_associations.find_or_create_by(post: post) if post.present?
      product_assoc = collection.collection_product_associations.find_or_create_by(product: product)

      schedule_workers(collection) if post_assoc&.errors.blank? && product_assoc.errors.empty?

      { post_association: post_assoc, product_association: product_assoc }
    end
  end

  def set_post(collections: [], post:, current_user:)
    post.collection_post_associations.joins(:collection)
      .where('collections.user_id' => current_user.id)
      .where.not('collections.id' => collections.map(&:id)).destroy_all

    collections.each do |collection|
      add(collection, post)
    end
    post.reload
  end

  # Note(jag): Add product to one or more collections
  # removes product from all collections for current user
  # when empty collection list is passed
  def set_product(collections: [], product:, current_user:)
    product.collection_product_associations.joins(:collection)
      .where('collections.user_id' => current_user.id)
      .where.not('collections.id' => collections.map(&:id)).destroy_all

    collections.each do |collection|
      add(collection, product)
    end
    product.reload
  end

  def remove(collection, object)
    raise 'Either post or product are required' if object.nil? && %w(Post Product).exclude?(object.class.name)

    post, product = post_and_product_by_object_type(object)

    post_assoc = collection.collection_post_associations.find_by(post: post)
    product_assoc = collection.collection_product_associations.find_by(product: product)

    post_assoc.destroy! if post_assoc.present?
    product_assoc.destroy! if product_assoc.present?

    { post_association: post_assoc, product_association: product_assoc }
  end

  def remove_assoc(assoc)
    assoc.destroy! if assoc.present?
    assoc
  end

  def schedule_workers(collection)
    Collections::AssignTopicsWorker.perform_later(collection)
  end

  private

  def post_and_product_by_object_type(object)
    if object.is_a? Post
      post = object
      product = object.new_product
    elsif object.is_a? Product
      post = object.latest_post
      product = object
    else
      raise 'Object passed should be either type post or product'
    end
    [post, product]
  end
end
