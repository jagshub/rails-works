# frozen_string_literal: true

class Products::Form
  include MiniForm::Model

  model :product, attributes: Product::SCRAPABLE_FIELDS, save: true

  attr_reader :source

  def initialize(product = nil, source_klass:)
    @product = product.presence || Product.new
    # NOTE(DZ): This only works with webshrinker for now. Used in #categories
    @source = source_klass.name.demodulize.downcase
  end

  # NOTE(DZ): Currently, this only adds category associations.
  def categories=(categories)
    found_categories = Products::Category.where(name: categories)
    (found_categories - product.categories).each do |category|
      Products::CategoryAssociation.create!(
        product: product,
        category: category,
        source: source,
      )
    end
  end
end
