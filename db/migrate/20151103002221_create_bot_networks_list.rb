class CreateBotNetworksList < ActiveRecord::Migration
  def change
    create_table :bot_networks do |t|
      t.inet :netmask, null: false
      t.text :description, null: true
      t.text :source

      # NOTE(andreasklinger): meta attributes
      t.timestamps null: false
    end

    add_index :bot_networks, [:netmask], using: 'btree'

    # Note(andreasklinger): enabling gist index for performance
    #   http://michael.otacoo.com/postgresql-2/postgres-9-4-feature-highlight-gist-inet-datatype/
    execute 'CREATE INDEX bot_networks_netmask_gist ON bot_networks USING gist (netmask inet_ops)'
  end
end
