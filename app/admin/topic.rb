# frozen_string_literal: true

ActiveAdmin.register Topic do
  menu label: 'Topic', parent: 'Posts'

  permit_params :name, :description, :image, :emoji, :kind, :parent_id, aliases_attributes: %i(id name _destroy)

  config.batch_actions = false

  filter :name
  filter :slug
  filter :posts_count, as: :numeric
  filter :followers_count, as: :numeric

  controller do
    defaults finder: :find_by_slug!

    def scoped_collection
      Topic.includes(:aliases)
    end

    def new
      @topic = Admin::TopicForm.new
    end

    def create
      @topic = Admin::TopicForm.new
      @topic.update permitted_params[:topic]

      respond_with @topic, location: admin_topics_path
    end

    def edit
      @topic = Admin::TopicForm.new Topic.find_by_slug!(params[:id])
    end

    def update
      @topic = Admin::TopicForm.new Topic.find_by_slug!(params[:id])
      @topic.update permitted_params[:topic]

      respond_with @topic, location: admin_topics_path
    end
  end

  index do
    id_column
    column :image do |topic|
      image_preview_hint(topic.image_url, '', image_url_suffix: '?auto=format&w=80&h=80')
    end
    column :emoji
    column :name
    column :slug
    column :kind
    column :parent
    column 'Aliases' do |topic|
      topic.aliases.map(&:name).join(', ')
    end
    column 'Posts Count', sortable: :posts_count do |topic|
      div class: 'count' do
        topic.posts_count
      end
    end
    column 'Followers Count', sortable: :followers_count do |topic|
      div class: 'count' do
        topic.followers_count
      end
    end
    actions defaults: false do |topic|
      [
        link_to('View in site', topic_path(topic)),
        link_to('View', admin_topic_path(topic)),
        link_to('Edit', admin_topic_path(topic)),
      ].join(' ').html_safe
    end
  end

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :slug
      row :kind
      row :parent
      row 'Aliases' do
        topic.aliases.map(&:name).join(', ')
      end
      row 'Posts count' do
        topic.posts.count
      end
      row 'Followers count' do
        topic.followers.count
      end
      row 'Image' do
        image_preview_hint(topic.image_url, '', image_url_suffix: '?auto=format&w=80&h=80')
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'Topic' do
      f.semantic_errors(*f.object.errors.attribute_names)
      f.input :name, as: :string
      f.input :description, as: :string
      f.input :emoji, as: :string
      f.input :kind, as: :select, collection: Topic.kinds.keys.to_a
      f.input :parent_id
      f.input :image, as: :file, hint: image_preview_hint(f.object.image_url, '', image_url_suffix: '?auto=format&w=80&h=80')
    end
    f.inputs 'Aliases' do
      f.has_many :aliases, allow_destroy: true, heading: 'Names for searching. Always converted to lowercase. Topic name automatically included.' do |form|
        form.input :name, label: 'Alias', hint: form.object.name == f.object.name.try(:downcase) ? 'Topic name. Used for faster searching.' : ''
      end
    end
    f.actions
  end

  action_item :new_import, only: :index do
    link_to 'Import', action: 'new_import'
  end

  collection_action :new_import do
    @import = Admin::Topics::ImportCSV.new
  end

  collection_action :import, method: :post do
    @import = Admin::Topics::ImportCSV.new

    if @import.update params.require(:import).permit(:csv)
      redirect_to admin_topics_path, notice: "Imported #{ @import.topics_count } topic(s)"
    else
      render :new_import, import: @import
    end
  end
end
