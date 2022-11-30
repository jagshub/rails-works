class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user, null: false, index: true
      t.references :subject, polymorphic: true
      t.string :verb, null: false
      t.references :object, polymorphic: true
      t.datetime :seen_at
      t.timestamps null: false
    end
  end
end
