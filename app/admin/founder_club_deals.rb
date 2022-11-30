# frozen_string_literal: true

ActiveAdmin.register FounderClub::Deal do
  Admin::AddTrashing.call(self)
  Admin::UseForm.call(self, FounderClub.admin_deal_form)

  menu label: 'Deals', parent: 'Founder Club'

  permit_params FounderClub.admin_deal_form.attribute_names + [{ badges: [] }]

  config.batch_actions = false
  config.per_page = 40
  config.paginate = true

  scope(:active, default: true, &:active)
  scope(:inactive, &:inactive)

  actions :all

  filter :title

  index pagination_total: true do
    column :id
    column :title
    column :company_name
    column :product
    column :active
    column :priority
    column :created_at
    column :trashed_at
    column :redemption_method
    column :claims_count do |resource|
      link_to resource.claims_count, admin_founder_club_claims_path(q: { deal_id_eq: resource.id })
    end
    column do |resource|
      link_to 'Codes', admin_founder_club_redemption_codes_path(q: { deal_id_eq: resource.id })
    end
    actions
  end

  controller do
    def scoped_collection
      end_of_association_chain.by_priority
    end
  end

  form do |f|
    f.inputs 'Listing information' do
      f.input :title, hint: 'Max 60 characters.'
      f.input :company_name, hint: 'Will be used in UI if deal does not have logo'
      f.input :value, hint: 'Example: "Up to $100" or "$100"'
      f.input :logo, as: :file, hint: image_preview_hint(f.object.logo_url, 'Company logo (white)')
      f.input :logo_with_colors, as: :file, hint: image_preview_hint(f.object.logo_with_colors_url, 'Company logo (with colors for claim modal)')
      f.input :summary, hint: 'Max 200 characters.'
      f.input :priority, as: :number, hint: 'Used for ordering. Bigger the better. Default: 0.'
      f.input :active, as: :boolean, label: 'Is it visible in deals listing?'
      f.input :product_id, as: :reference, label: 'Product ID'
    end
    f.inputs 'Claim information' do
      f.input :redemption_url, hint: 'Use [code] to specify where code to be added: Example: https://site.com/register?code=[code]'
      f.input :details, as: :text, hint: 'Accepts HTML code'
      f.input :terms, as: :text, hint: 'Accepts HTML code'
      f.input :how_to_claim, as: :text, hint: 'Accepts HTML code'
    end
    f.inputs 'Redemption codes' do
      f.input :redemption_method, as: :select, collection: FounderClub::Deal.redemption_methods.keys, include_blank: false
      f.input :unlimited_code, label: 'Single redemption code', as: :string, hint: 'All customers receive the same code'

      hint = "
        CVS with one column, the codes.
        #{ link_to(
          "existing codes: (#{ f.object.deal.redemption_codes.limited.count })",
          admin_founder_club_redemption_codes_path(q: { deal_id: f.object.deal.id }),
        ) }
      "

      f.input :limited_codes_csv, as: :file, label: 'List of redemption codes', hint: raw(hint)
      f.input :badges, label: 'Badges', as: :select, collection: ::FounderClub::Deal::BADGES, multiple: true
    end
    f.actions
  end
end
