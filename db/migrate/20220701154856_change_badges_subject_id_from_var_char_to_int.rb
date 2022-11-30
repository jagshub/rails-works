class ChangeBadgesSubjectIdFromVarCharToInt < ActiveRecord::Migration[6.1]
  def change
    safety_assured {
      execute <<~SQL
        SET statement_timeout = '100s';
      SQL

      change_column :badges, :subject_id, :integer, using: 'subject_id::integer'

      execute <<~SQL
        SET statement_timeout = DEFAULT;
      SQL
    }
  end
end