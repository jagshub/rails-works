class CreateSipPollVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :sip_poll_votes do |t|
      t.references :sip_poll, foreign_key: true, null: false
      t.references :sip_poll_option, foreign_key: true, null: false
      t.string :ip
      t.string :user_agent
      t.string :device

      t.timestamps
    end
  end
end
