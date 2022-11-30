# frozen_string_literal: true

module ExecSql
  extend self

  def call(sql, *args)
    sql = ActiveRecord::Base.sanitize_sql([sql, *args]) if args.any?
    ActiveRecord::Base.connection.execute(sql)
  end

  def count(sql, **args)
    row = call(sql, **args).first
    return 0 unless row

    row.first.second || 0
  end

  def sanitize_sql(sql, *args)
    ActiveRecord::Base.sanitize_sql([sql, *args])
  end
end
