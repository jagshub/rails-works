class CopyProductStateToPosts < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      execute(<<~SQL)
        UPDATE posts
        SET product_state = legacy_products.state
        FROM legacy_products
        WHERE legacy_products.id = posts.product_id
      SQL
    end
  end

  def down
  end
end
