# frozen_string_literal: true

module Admin
  class CollectionForm
    include ActiveModel::Model

    attr_reader :collection, :new_products

    ATTRIBUTES = %i(name slug title user_id featured_at description personal).freeze

    delegate(*ATTRIBUTES, to: :collection)
    delegate(*ATTRIBUTES.map { |a| "#{ a }=" }, to: :collection)

    delegate :id, :persisted?, :collection_product_associations, to: :collection
    validates :collection, nested: true
    validates :new_products, nested: true

    class << self
      def reflect_on_association(name)
        Collection.reflect_on_association name
      end

      def attributes
        ATTRIBUTES
      end
    end

    def initialize(user, collection = Collection.new)
      @user       = user
      @collection = collection
      @new_products = []
    end

    def attributes=(attributes)
      attributes.each do |attr, value|
        public_send "#{ attr }=", value
      end
    end

    def update(attributes = nil)
      self.attributes = attributes if attributes.present?

      if valid?
        collection.save!
        collection.products += new_products.map do |product_form|
          product_form.publish
          product_form.product
        end
        true
      else
        false
      end
    end

    def to_model
      collection
    end

    def to_param
      id
    end

    def products
      collection.products.select(&:new_record?)
    end

    def collection_product_associations_attributes=(items)
      items.values.each do |hash|
        if hash[:id]
          assoc = collection.collection_product_associations.find(hash[:id])
          if hash[:_destroy] == '1'
            assoc.destroy!
          else
            assoc.update! product_id: hash[:product_id]
          end
        else
          collection.collection_product_associations.find_or_initialize_by product_id: hash[:product_id]
        end
      end
    end
  end
end
