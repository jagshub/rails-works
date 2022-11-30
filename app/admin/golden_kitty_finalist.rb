# frozen_string_literal: true

ActiveAdmin.register GoldenKitty::Finalist do
  menu label: 'Finalist', parent: 'Golden Kitty'
  actions :all

  permit_params :post_id, :golden_kitty_category_id, :winner, :csv_file, :position

  config.per_page = 20
  config.paginate = true

  filter :golden_kitty_category, collection: -> { GoldenKitty::Category.by_year.by_priority.map { |category| ["#{ category.name } #{ category.year }", category.id] } }
  filter :post_name, as: :string
  filter :post_slug, as: :string
  filter :winner, as: :check_boxes

  controller do
    def scoped_collection
      GoldenKitty::Finalist.includes(:golden_kitty_category, :post)
    end

    def create
      inputs = permitted_params[:golden_kitty_finalist]

      if inputs[:csv_file].present?
        ::GoldenKitty::CreateFinalistFromCsv.call inputs[:csv_file]

        redirect_to admin_golden_kitty_finalists_path
      else
        finalist = ::GoldenKitty::Finalist.find_or_create_by! post_id: inputs[:post_id], golden_kitty_category_id: inputs[:golden_kitty_category_id], winner: inputs[:winner]

        redirect_to admin_golden_kitty_finalist_path(finalist)
      end
    end
  end

  index do
    selectable_column

    column :id
    column :post
    column :golden_kitty_category
    column :credible_votes_count
    column :votes_count
    column :winner
    column :position
    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :post_id
      f.input :golden_kitty_category, collection: GoldenKitty::Category.by_year.by_priority.map { |category| ["#{ category.name } #{ category.year }", category.id] }
      f.input :winner
      f.input :position
    end

    unless f.object.persisted?
      panel 'Upload csv file (for bulk creation)' do
        f.inputs do
          f.input :csv_file, as: :file
          f.br
          f.div 'Format: category_id, post_slug'
        end
      end
    end

    f.actions
  end
end
