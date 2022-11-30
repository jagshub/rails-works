class CreateSeoStructuredDataValidationMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :seo_structured_data_validation_messages do |t|
      t.references :subject, null: false, polymorphic: true, index: { name: 'index_seo_structured_data_validaton_on_subject' }
      t.string :messages, array: true, default: [], null: false
      t.timestamps null: false
    end
  end
end
