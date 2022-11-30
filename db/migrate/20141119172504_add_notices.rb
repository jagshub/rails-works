class AddNotices < ActiveRecord::Migration
  class MigrationNotice < ApplicationRecord
    self.table_name = 'notices'

    enum layout: { simple: 0, newsletter: 1, twitter_follow: 2 }
    enum colorset: { grey: 0, blue: 1 }
  end

  def change
    create_table :notices do |t|
      t.boolean    :enabled, null: false, default: false
      t.integer    :placement, null: false, default: 0
      t.integer    :priority, null: false, default: 0
      t.integer    :layout, null: false, default: MigrationNotice.layouts[:simple]
      t.integer    :colorset, null: false, default: MigrationNotice.colorsets[:grey]
      t.json       :conditions, null: false, default: {}
      t.text       :message_text, null: false
      t.references :message_user
      t.text       :button_url
      t.text       :button_text
    end

    reversible do |d|
      d.up do
        MigrationNotice.create!(
          enabled: true,
          layout: :newsletter,
          message_text: 'Get the best new product discoveries in your inbox daily!',
          conditions: { user_logged_out: true },
          priority: 10,
          placement: 0
        )
        MigrationNotice.create!(
          enabled: true,
          layout: :twitter_follow,
          message_text: 'Follow <strong>@ProductHunt</strong> on Twitter for the latest hunts and updates.',
          priority: 10,
          placement: 2,
          colorset: :blue
        )
      end
    end
  end
end
