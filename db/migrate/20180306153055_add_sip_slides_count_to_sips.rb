class AddSipSlidesCountToSips < ActiveRecord::Migration[5.0]
  def change
    add_column :sips, :sip_slides_count, :integer
  end
end
