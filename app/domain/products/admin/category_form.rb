# frozen_string_literal: true

class Products::Admin::CategoryForm < Admin::BaseForm
  model :category,
        attributes: %i(parent_id name slug description reviewed),
        save: true

  main_model :category, Products::Category

  validates :name, presence: true

  def initialize(category = nil)
    @category = category.presence || Products::Category.new
  end
end
