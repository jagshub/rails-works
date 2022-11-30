class CreateEmailProviderDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :email_provider_domains do |t|
      t.string :value, null: false, index: true
      t.references :added_by, null: false
      t.timestamps
    end
  end
end
