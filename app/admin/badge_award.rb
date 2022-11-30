# frozen_string_literal: true

ActiveAdmin.register Badges::Award do
  menu label: 'User Award Types', parent: 'Badges'

  config.clear_action_items!
  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  actions :all, except: :destroy

  permit_params :name, :description, :image, :active, :created_at, :updated_at

  filter :id
  filter :name
  filter :active

  index do
    selectable_column
    column :id
    column :image do |award|
      image_preview_hint(
        award.image_url,
        '',
        image_url_suffix: '?auto=format&w=40&h=40',
      )
    end
    column :name
    column :description
    column :active
    actions
  end

  controller do
    def update
      @award = Badges::Award.find(params[:id])
      @award.update permitted_params[:badges_award]

      respond_with @award, location: edit_admin_badges_award_path
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Award' do
      f.input :image,
              as: :file,
              hint: image_preview_hint(
                f.object.image_url,
                '',
                image_url_suffix: '?auto=format&w=80&h=80',
              )
      f.input :name, as: :string, label: 'Award display name'
      f.input :description, as: :string, label: 'Award description'
    end

    f.actions
  end
end
