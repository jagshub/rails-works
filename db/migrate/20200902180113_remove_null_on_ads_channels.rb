class RemoveNullOnAdsChannels < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      reversible do |dir|
        dir.up do
          execute <<-SQL
            UPDATE ads_channels
            SET bundle = 'homepage'
            WHERE bundle IS NULL
            AND kind = 'feed'
          SQL

          execute <<-SQL
            UPDATE ads_channels
            SET bundle = 'other'
            WHERE bundle IS NULL
            AND kind = 'sidebar'
          SQL
        end

        dir.down do
          execute <<-SQL
            UPDATE ads_channels
            SET bundle = NULL
            WHERE bundle in ('homepage', 'other')
          SQL
        end
      end

      change_column_null :ads_channels, :bundle, false
    end
  end
end
