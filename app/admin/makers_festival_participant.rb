# frozen_string_literal: true

ActiveAdmin.register MakersFestival::Participant do
  menu label: 'Participant', parent: 'Makers Festival'
  actions :all

  csv do
    column :id
    column 'Category' do |participant|
      participant.makers_festival_category.name
    end
    column 'User' do |participant|
      participant.user.username
    end
    column :project_details
    column :external_link
    column :votes_count
    column :credible_votes_count
    column :finalist
    column :winner
    column :position
    (0..15).each do |index|
      column "Maker ##{ index + 1 } Name" do |participant|
        participant.makers[index]&.name
      end

      column "Maker ##{ index + 1 } Username" do |participant|
        participant.makers[index]&.username
      end

      column "Maker ##{ index + 1 } Email" do |participant|
        participant.makers[index]&.email
      end
    end
  end

  permit_params %i(
    user_id
    makers_festival_category_id
    external_link
    finalist
    winner
    position
    project_name
    project_tagline
    project_thumbnail
  )

  config.per_page = 20
  config.paginate = true

  filter :makers_festival_category_id
  filter :user_id
  filter :finalist
  filter :winner
  filter :position

  scope(:green_earth, default: true) do |scope|
    # Note(Dhruv): This is a temporary solution to filter participants on the latest
    # makers festival. Later add festival_id to participant and give festival filter on this page
    scope
      .joins(makers_festival_category: :makers_festival_edition)
      .merge(MakersFestival::Edition.where(slug: 'green-earth'))
  end
  scope(:all, &:all)

  batch_action :add_finalist do |ids|
    batch_action_collection.find(ids).each do |participant|
      participant.update! finalist: true
    end

    redirect_to admin_makers_festival_participants_path, notice: 'Added finalist'
  end

  batch_action :remove_finalist do |ids|
    batch_action_collection.find(ids).each do |participant|
      participant.update! finalist: false
    end

    redirect_to admin_makers_festival_participants_path, alert: 'Removed finalist'
  end

  controller do
    def scoped_collection
      MakersFestival::Participant.includes(:makers_festival_category, :user)
    end
  end

  index do
    selectable_column

    column :id
    column :makers_festival_category
    column :user
    column :project_details
    column :external_link
    column :votes_count
    column :credible_votes_count
    column :finalist
    column :winner
    column :position
    column 'Makers' do |participant|
      link_to 'View Makers', admin_makers_festival_makers_url('q[makers_festival_participant_id_equals]': participant.id)
    end

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :user_id
      f.input :makers_festival_category_id
      f.input :project_name
      f.input :project_tagline
      div render('thumbnail', participant: f.object)
      f.input :external_link, hint: 'Should include http:// or https:// (Example: http://example.com)'
      f.input :finalist
      f.input :winner
      f.input :position
    end

    f.actions
  end
end
