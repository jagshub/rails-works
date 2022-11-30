class AddMd5IndexForUsers < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute <<-SQL
      CREATE INDEX CONCURRENTLY index_notifications_subscribers_on_hashed_email ON notifications_subscribers (md5(lower(email)));
    SQL

  end

  def down
    execute <<-SQL
      DROP INDEX index_notifications_subscribers_on_hashed_email;
    SQL
  end
end
