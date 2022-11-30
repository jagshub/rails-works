# frozen_string_literal: true

ActiveAdmin.register LinkSpect::Log do
  menu label: 'Link Inspect Logs', parent: 'Others'

  config.per_page = 20
  config.paginate = true

  permit_params %i(external_link blocked expires_at source)

  filter :external_link
  filter :blocked
  filter :source
  filter :expires_at

  scope(:all, default: true)
  scope(:active, &:active)

  index do
    selectable_column

    column :id
    column :external_link
    column :blocked
    column :expires_at
    column :source

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :external_link
      f.input :blocked
      f.input :expires_at, as: :datetime_picker, hint: "Don't have expires more than a day or month or max year without strong reason and checks."
      f.input :source, hint: 'Should be admin', selected: 'admin'
    end

    f.actions
  end
end
