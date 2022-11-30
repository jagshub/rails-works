class CreateInputSuggestions < ActiveRecord::Migration[5.0]
  def change
    create_table :input_suggestions do |t|
      t.citext :name, null: false
      t.integer :kind, null: false

      t.timestamps
    end

    add_index :input_suggestions, %i(name kind), unique: true
  end
end
