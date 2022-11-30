class ChangeSettingsToHashLikeStructure < ActiveRecord::Migration
  def change
    drop_table :settings
    create_table :settings do |t|
      t.string :name
      t.string :value
      t.timestamps
    end

    Setting.reset_column_information
    Setting.create [ { name: 'rank_floor', value: '0.0019' },
                     { name: 'rank_time_multiplier', value: '1.35' },
                     { name: 'rank_time_addition', value: '900' },
                     { name: 'rank_upvote_addition', value: '20' },
                     { name: 'rank_show_debug', value: '0' } ]
  end
end
