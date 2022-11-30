class RemoveSocialDigest < ActiveRecord::Migration
  def change
    drop_table :social_digests
  end
end
