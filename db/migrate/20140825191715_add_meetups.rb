class AddMeetups < ActiveRecord::Migration
  def change
    create_table :meetups do |t|
      t.date :event_date, null: false
      t.text :title, null: false
      t.text :description, null: false
      t.text :event_url, null: false
    end

    create_table :meetup_host_associations do |t|
      t.references :meetup, null: false
      t.references :user, null: false
    end
  end
end
