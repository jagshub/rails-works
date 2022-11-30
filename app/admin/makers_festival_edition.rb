# frozen_string_literal: true

ActiveAdmin.register MakersFestival::Edition do
  menu label: 'Edition', parent: 'Makers Festival'
  actions :all

  permit_params(
    :sponsor,
    :start_date,
    :name,
    :tagline,
    :description,
    :prizes,
    :discussion_preview,
    :embed_url,
    :banner,
    :social_banner,
    :result_url,
    :registration,
    :registration_ended,
    :submission,
    :submission_ended,
    :voting,
    :voting_ended,
    :result,
    :maker_group_id,
    :share_text,
  )

  config.per_page = 20
  config.paginate = true

  filter :sponsor
  filter :start_date

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  index do
    selectable_column

    column :id
    column :name
    column :start_date
    column :tagline
    column :sponsor
    column :slug

    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :start_date
      row :tagline
      row :sponsor
      row :slug
      row :description
      row :prizes
      row :banner do |edition|
        image_preview_hint(edition.banner_url, '', image_url_suffix: '?auto=format&w=1280&h=420')
      end
      row :social_banner do |edition|
        image_preview_hint(edition.social_banner_url, '', image_url_suffix: '?auto=format&w=1280&h=420')
      end
      row :discussion_preview do |edition|
        image_preview_hint(edition.discussion_preview_url, '', image_url_suffix: '?auto=format&w=400&h=300')
      end
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :start_date
      f.input :registration
      f.input :registration_ended
      f.input :submission
      f.input :submission_ended
      f.input :voting
      f.input :voting_ended
      f.input :result
      f.input :name, required: true
      f.input :sponsor
      f.input :tagline, required: true
      f.input :share_text
      f.input :result_url
      f.input :banner, as: :file, hint: image_preview_hint(f.object.banner_url, 'Upload image of size "2560 x 840px"', image_url_suffix: '?auto=format&w=640&h=210')
      f.input :social_banner, as: :file, hint: image_preview_hint(f.object.social_banner_url, 'Upload image of size "1200 x 627px"', image_url_suffix: '?auto=format&w=640&h=210')
      f.input :description, as: :text, hint: 'Accepts HTML code', required: true
      f.input :prizes, as: :text, hint: 'Accepts HTML code', required: true
      f.input :discussion_preview, as: :file, hint: image_preview_hint(f.object.discussion_preview_url, 'Upload image of size "1440 x 832px"', image_url_suffix: '?auto=format&w=400&h=300')
      f.input :embed_url
      f.input :maker_group_id
    end

    f.actions
  end
end
