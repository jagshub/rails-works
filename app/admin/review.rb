# frozen_string_literal: true

ActiveAdmin.register Review do
  Admin::UseForm.call self, Reviews::Admin::Form

  config.batch_actions = false

  menu label: 'Reviews', parent: 'Products'

  scope(:all, default: true, &:all)
  scope(:with_sentiment)
  scope(:with_rating)

  filter :id
  filter :product_name, as: :string
  filter :post_name, as: :string
  filter :sentiment
  filter :rating
  filter :currently_using, as: :select, collection: Review.currently_usings
  filter :user_id
  filter :created_at
  filter :votes_count
  filter :credible_votes_count
  filter :score

  controller do
    def scoped_collection
      Review.includes %i(product user post)
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :user_id, required: true, as: :hidden, input_html: { value: current_user.id }
      f.input :product_id, required: true
      f.input :post_id
      f.input :sentiment
      f.input :rating, min: 1, max: 5, step: 1, label: 'Rating (1 to 5)'
      f.input :score, input_html: { readonly: true }
      f.input :score_multiplier
      f.input :overall_experience
      f.input :currently_using, as: :select, collection: Review.currently_usings.keys
    end

    unless f.object.new_record?
      f.inputs 'Review Tag associations' do
        f.has_many :tag_associations, allow_destroy: true, new_record: true do |form|
          form.input :review_tag_id
          form.input :sentiment, as: :select, collection: ReviewTagAssociation.sentiments.keys
        end
      end
    end

    f.actions
  end

  action_item :hide_review, only: :show, if: proc { !resource.hidden_at? } do
    link_to 'Hide Review', action: :hide_review
  end

  action_item :unhide_review, only: :show, if: proc { resource.hidden_at? } do
    link_to 'Unhide Review', action: :unhide_review
  end

  member_action :hide_review do
    resource.hide!

    redirect_to resource_path, notice: 'Review was hidden'
  end

  member_action :unhide_review do
    resource.unhide!

    redirect_to resource_path, notice: 'Review was unhidden'
  end

  index do
    column :user
    column :product
    column :post
    column :sentiment
    column :rating
    column :votes_count
    column :credible_votes_count
    column :score_multiplier
    column :score
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :product
      row :post
      row :user
      row :sentiment
      row :rating

      row :positive_tags do |review|
        review.positive_tags.map(&:positive_label)
      end

      row :negative_tags do |review|
        review.negative_tags.map(&:negative_label)
      end

      row :overall_experience
      row :currently_using
      row :votes_count
      row :credible_votes_count
      row :score_multiplier
      row :score
      row :hidden_at
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
