class CreateFundingSurveys < ActiveRecord::Migration[6.1]
  def change
    create_table :funding_surveys do |t|
      t.references :post, foreign_key: true, index: { unique: true }

      t.boolean :have_raised_vc_funding, null: true
      t.string :funding_round, null: true
      t.string :funding_amount, null: true
      t.boolean :interested_in_vc_funding, null: true
      t.boolean :interested_in_being_contacted, null: true
      t.boolean :share_with_investors, null: true

      t.timestamps
    end
  end
end
