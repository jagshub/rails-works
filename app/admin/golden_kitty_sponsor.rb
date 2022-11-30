# frozen_string_literal: true

ActiveAdmin.register GoldenKitty::Sponsor do
  menu label: 'Sponsor', parent: 'Golden Kitty'
  actions :all

  permit_params(
    :name,
    :description,
    :url,
    :website,
    :logo,
    :left_image,
    :right_image,
    :dark_ui,
    :bg_color,
  )

  config.per_page = 20
  config.paginate = true

  filter :name
  filter :website

  controller do
    def create
      @golden_kitty_sponsor = GoldenKitty::Sponsor.new
      @golden_kitty_sponsor.update permitted_params[:golden_kitty_sponsor]

      redirect_to admin_golden_kitty_sponsor_path(@golden_kitty_sponsor), notice: 'Sponsor added!'
    end
  end

  index do
    selectable_column

    column :id
    column :name
    column :logo do |sponsor|
      image_preview_hint(sponsor.logo_url, '', image_url_suffix: '?auto=format&w=250&h=80')
    end
    column :website
    column :dark_ui
    column :description

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :name
      f.input :description
      f.input :url
      f.input :website
      f.input :dark_ui
      f.input :bg_color
      f.input :logo, as: :file, hint: image_preview_hint(f.object.logo_url, 'Upload image of size "500 x 160px"', image_url_suffix: '?auto=format&w=250&h=80')
      f.input :right_image, as: :file, hint: image_preview_hint(f.object.right_image_url, 'Upload image of size "1060 x 1220px"', image_url_suffix: '?auto=format&w=530&h=610')
      f.input :left_image, as: :file, hint: image_preview_hint(f.object.left_image_url, 'Upload image of size "1820 x 580px"', image_url_suffix: '?auto=format&w=910&h=290')
    end

    f.actions
  end
end
