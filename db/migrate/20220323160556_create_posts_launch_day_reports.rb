class CreatePostsLaunchDayReports < ActiveRecord::Migration[6.1]
  def change
    create_table :posts_launch_day_reports do |t|
      t.references :post, foreign_key: true, null: false
      t.string :s3_key, null: false
      t.timestamps
    end
  end
end
