class AddTemplateToUpcomingPageVariant < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_variants, :template_name, :string, null: false, default: 'default'
  end
end
