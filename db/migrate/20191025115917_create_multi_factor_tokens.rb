class CreateMultiFactorTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :multi_factor_tokens do |t|
      t.belongs_to :user, index: true, foreign_key: true, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end
