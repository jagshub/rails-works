class TruncateHeadlinesToMakeUsersValid < ActiveRecord::Migration
  def up
    sql = <<-QUERY
      update users
         set headline = substring(headline from 0 for 39) || '…'
       where length(headline) > 40;
    QUERY

    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    # noop
  end
end
