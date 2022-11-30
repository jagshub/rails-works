class ValidateLegacyLinkPostForeignKey < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :legacy_product_links, :posts
  end
end
