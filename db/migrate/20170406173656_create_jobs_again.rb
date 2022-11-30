class CreateJobsAgain < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.text :image_uuid, null: false
      t.text :company_name, null: false
      t.text :job_title, null: false
      t.text :url, null: false

      t.boolean :published, null: false, default: false
      t.timestamps null: false
    end
  end
end
