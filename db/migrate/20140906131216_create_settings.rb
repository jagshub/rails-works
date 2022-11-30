class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.float :rank_floor
      t.float :rank_time_multiplier
      t.integer :rank_time_addition
      t.integer :rank_upvote_addition
      t.boolean :rank_show_debug

      t.timestamps
    end

    # create the default settings
    Setting.create rank_floor: 0.0019, rank_time_multiplier: 1.35,
                   rank_time_addition: 900, rank_upvote_addition: 20,
                   rank_show_debug: false
  end
end
