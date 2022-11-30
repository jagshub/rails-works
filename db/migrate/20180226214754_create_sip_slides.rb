class CreateSipSlides < ActiveRecord::Migration[5.0]
  def change
    create_table :sip_slides do |t|
      t.references :sip, foreign_key: true
      t.string :slide_type, null: false
      t.integer :order, null: false
      t.string :intro_title
      t.text :intro_description
      t.text :intro_background
      t.text :text
      t.string :photo
      t.string :video
      t.string :article_link
      t.string :article_icon
      t.string :article_publication
      t.string :article_author
      t.text :article_snippet
      t.string :tweet
      t.string :producthunt
      t.references :sip_poll, foreign_key: true, null: true

      t.timestamps
    end
  end
end
