class CreateCompaniesAndJobs < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.uuid :logo_uuid, null: false
      t.string :name, null: false
      t.string :tagline, null: false
      t.references :user, null: false, index: true, foreign_key: true
      t.timestamps null: false
    end

    create_table :company_post_associations do |t|
      t.references :company, null: false, index: true, foreign_key: true
      t.references :post, null: false, index: true, foreign_key: true
      t.timestamps null: false
    end

    add_index :company_post_associations, [:company_id, :post_id], unique: true

    create_table :jobs do |t|
      t.references :company, null: false, index: true, foreign_key: true
      t.string :location, null: false
      t.string :title, null: false
      t.string :url, null: false
      t.boolean :remote, null: false, default: false
      t.timestamps null: false
    end
  end
end
