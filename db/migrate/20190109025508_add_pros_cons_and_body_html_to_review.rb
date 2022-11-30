class AddProsConsAndBodyHtmlToReview < ActiveRecord::Migration[5.0]
  def change
    add_column :reviews, :pros_html, :text
    add_column :reviews, :cons_html, :text
    add_column :reviews, :body_html, :text
  end
end
