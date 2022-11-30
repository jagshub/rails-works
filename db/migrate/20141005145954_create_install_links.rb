class CreateInstallLinks < ActiveRecord::Migration
  def change
    create_table :install_links do |t|
      t.integer :post_id, nil: false
      t.string :url, nil: false
      t.string :shortened_link, nil: false
      t.integer :platform, nil: false

      t.timestamps
    end

    add_index :install_links, :shortened_link, unique: true
    add_foreign_key(:install_links, :posts)

  end
end
