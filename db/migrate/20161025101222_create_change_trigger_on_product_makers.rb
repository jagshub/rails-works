class CreateChangeTriggerOnProductMakers < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER product_makers_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON product_makers FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS product_makers_change_trigger ON product_makers CASCADE;
    SQL
  end
end
