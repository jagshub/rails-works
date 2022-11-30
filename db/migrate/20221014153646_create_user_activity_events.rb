# frozen_string_literal: true

class CreateUserActivityEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :user_activity_events do |t|
      t.references :user, foreign_key: true, null: false, index: false
      t.references :subject, polymorphic: true, null: false, index: true
      t.timestamp :occurred_at, null: false

      t.index %i(user_id subject_type subject_id), unique: true, name: 'index_user_activities_unique'

      t.timestamps null: false
    end
  end
end
