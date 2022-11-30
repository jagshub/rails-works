# frozen_string_literal: true

ActiveAdmin.register Anthologies::Story, as: 'Stories' do
  Admin::UseForm.call self, Anthologies::Admin::StoryForm

  menu label: 'Story', parent: 'Others'

  actions :all

  controller do
    def scoped_collection
      Anthologies::Story.includes(:author)
    end

    def find_resource
      scoped_collection.friendly.includes(related_story_associations: [:related]).find(params[:id])
    end

    def show
      @story = find_resource
    end
  end

  config.per_page = 20
  config.paginate = true

  filter :title
  filter :slug

  index pagination_total: false do
    selectable_column

    column :id
    column :title
    column :slug
    column :mins_to_read
    column :category
    column :featured_position
    column 'created by - PH author' do |story|
      link_to story.author.name, admin_user_path(story.author), target: :blank
    end
    column 'Non-PH author name', &:author_name
    column 'Non-PH author url', &:author_url
    column :created_at
    column :published? do |story|
      story.published? ? story.published_at : 'No'
    end
    actions
  end

  action_item :show_link, only: %i(edit show) do
    link_to 'Public View Link', Routes.story_url(resource), target: :blank
  end

  action_item :edit_link, only: %i(edit show) do
    link_to 'Public Edit Link', Routes.edit_story_url(resource), target: :blank
  end

  show do
    attributes_table do
      row :id
      row :title
      row :description
      row 'created by - PH author', &:author
      row 'Non-PH author name', &:author_name
      row 'Non-PH author url', &:author_url
      row :mins_to_read
      row :category
      row :featured_position
      row :header_image_uuid
      row :header_image_credit
      row :body_html
      row :published_at
      row :created_at
      row :updated_at
    end

    panel 'Mentions' do
      table_for story.story_mentions_associations do
        column :id
        column :subject
      end
    end

    panel 'Related Stories' do
      table_for story.related_story_associations.includes(:related).order(position: :asc) do
        column :id
        column :related
        column :position
      end
    end
  end

  form do |f|
    if f.object.errors.any?
      f.inputs 'Errors' do
        f.object.errors.full_messages.join('|')
      end
    end

    f.inputs 'Details' do
      f.input :title, as: :string
      f.input :description, as: :string
      f.input :user_id, label: 'Created by - PH author', as: :number
      f.input :author_name,
              label: 'Non-PH author name',
              as: :string,
              hint: 'If left blank, twitter user name of created by - PH author will be used in share links for the story'

      f.input :author_url, label: 'Non-PH author url', as: :string
      f.input :mins_to_read, as: :number
      f.input :header_image_uuid, as: :string
      f.input :header_image_credit, as: :string
      f.input :category, as: :select, collection: Anthologies::Story.categories
      f.input :featured_position, as: :select, collection: Anthologies::Story.featured_positions.keys
      f.input :body_html, as: :text
      f.input :published_at, as: :datetime_picker
    end

    unless f.object.new_record?
      f.inputs 'Story Mentions' do
        f.has_many :story_mentions_associations,
                   allow_destroy: true,
                   new_record: true do |r|
                     r.input :subject_type, as: :select, collection: Anthologies::StoryMentionsAssociation.subject_types
                     r.input :subject_id
                   end
      end

      f.inputs 'Related Stories' do
        f.has_many :related_story_associations,
                   sortable: :position,
                   allow_destroy: true,
                   new_record: 'Add related story' do |r|
          r.input :related
        end
      end
    end

    f.actions
  end
end
