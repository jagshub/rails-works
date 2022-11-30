# frozen_string_literal: true

ActiveAdmin.register GoldenKitty::Fact do
  menu label: 'Fact', parent: 'Golden Kitty'
  actions :all

  permit_params(
    :description,
    :image,
    :category_id,
  )

  config.per_page = 20
  config.paginate = true

  controller do
    def create
      @golden_kitty_kitty = GoldenKitty::Fact.new
      @golden_kitty_kitty.update permitted_params[:golden_kitty_kitty]

      redirect_to admin_golden_kitty_kitty_path(@golden_kitty_kitty), notice: 'Fact added!'
    end
  end

  index do
    selectable_column

    column :id
    column :description
    column :category
    column :image do |fact|
      image_preview_hint(fact.image_url, '', image_url_suffix: '?auto=format&w=100&h=100')
    end

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :description
      f.input :category_id
      f.input :image, as: :file, hint: image_preview_hint(f.object.image_url, 'Upload image of size "800 x 800px"', image_url_suffix: '?auto=format&w=400&h=400')
    end

    f.actions
  end
end
