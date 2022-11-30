# frozen_string_literal: true

ActiveAdmin.register GoldenKitty::Category do
  menu label: 'Category', parent: 'Golden Kitty'
  actions :all

  permit_params %i(
    name
    tagline
    emoji
    year
    edition_id
    topic_id
    sponsor_id
    priority
    nomination_question
    slug
    voting_enabled_at
    icon
    social_image
    social_image_nomination
    social_image_pre_voting
    social_image_voting
    social_image_pre_result
    social_image_result
    people_category
  )

  config.per_page = 20
  config.paginate = true

  filter :name
  filter :year
  filter :edition_id

  controller do
    def scoped_collection
      GoldenKitty::Category.includes(:topic, :edition)
    end

    def create
      @golden_kitty_category = GoldenKitty::Category.new
      @golden_kitty_category.update! permitted_params[:golden_kitty_category]

      redirect_to admin_golden_kitty_category_path(@golden_kitty_category), notice: 'Category added!'
    end
  end

  index do
    selectable_column

    column :id
    column :edition
    column :name
    column :priority
    column :slug
    column :tagline
    column :emoji
    column :icon do |category|
      if category.icon_uuid.present?
        link_to(
          image_tag(category.icon_url, height: 30, width: 'auto'),
          category.icon_url,
          target: '_blank',
          rel: 'noopener',
        )
      end
    end
    column :nomination_question
    column :year
    column :sponsor
    column :topic
    column :voting_enabled_at
    column :social_image do |category|
      image_preview_hint(category.social_image_url, '', image_url_suffix: '?auto=format&w=250&h=80')
    end

    column 'Add Finalists' do |category|
      link_to 'Add', admin_posts_url(scope: 'golden_kitty', golden_kitty_category: category.id)
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :edition
      row :name
      row :priority
      row :slug
      row :tagline
      row :emoji
      row :icon do |category|
        if category.icon_uuid.present?
          link_to(
            image_tag(category.icon_url, height: 100, width: 'auto'),
            category.icon_url,
            target: '_blank',
            rel: 'noopener',
          )
        end
      end
      row :nomination_question
      row :year
      row :edition
      row :sponsor
      row :topic
      row :people_category
      row :voting_enabled_at
      GoldenKitty::Category.social_image_columns.map do |c|
        row c.to_sym do |category|
          if category.send(c).present?
            link_to(
              image_tag(category.send("#{ c }_url"), height: 100, width: 'auto'),
              category.send("#{ c }_url"),
              target: '_blank',
              rel: 'noopener',
            )
          end
        end
      end
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :priority
      f.input :year, as: :select
      f.input :edition_id
      f.input :voting_enabled_at, as: :datetime_picker
      f.input :name
      f.input :tagline
      f.input :slug
      f.input :emoji, hint: 'Emoji or an icon is required for a category'
      f.input :icon, as: :file, hint: image_preview_hint(f.object.icon_url, 'Preview')
      f.input :nomination_question
      f.input :topic_id
      f.input :sponsor_id
      f.input :people_category
    end

    f.inputs 'Social Image' do
      f.input :social_image, as: :file, hint: image_preview_hint(f.object.social_image_url, 'Default Social Image')
      f.input :social_image_nomination, as: :file, hint: image_preview_hint(f.object.social_image_nomination_url, 'During nomination this will be used')
      f.input :social_image_pre_voting, as: :file, hint: image_preview_hint(f.object.social_image_pre_voting_url, 'Between nomination end  & voting start this will be used')
      f.input :social_image_voting, as: :file, hint: image_preview_hint(f.object.social_image_voting_url, 'During voting  this will be used')
      f.input :social_image_pre_result, as: :file, hint: image_preview_hint(f.object.social_image_pre_result_url, 'Between voting end & result announced this will be used')
      f.input :social_image_result, as: :file, hint: image_preview_hint(f.object.social_image_result_url, 'When result announced this will be used')
    end

    f.actions
  end
end
