# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  controller do
    # NOTE(rstankov): Taken from activeadmin/activeadmin#2263
    # ActiveAdmin uses arbre for rendering partial caching is not available there
    helper_method :cache_arbre

    def cache_arbre(context, cache_key, options = {}, &block)
      if Rails.cache.exist?(cache_key)
        html = Rails.cache.read(cache_key)
        context.text_node(html)
      else
        Arbre::Element.new(context).build(&block)
        Rails.cache.write(cache_key, context.current_arbre_element.content, options)
      end
    end
  end

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel 'Recent Posts' do
          ul do
            Post.order('created_at DESC').limit(7).map do |post|
              li link_to(post.name, admin_post_path(post))
            end
          end
        end
      end

      # Note(Rahul): This causes timeout in dev
      if Rails.env.production?
        column do
          panel 'Stats' do
            div do
              cache_arbre(self, 'admin_dashboard', expires_in: 1.day) do
                ul do
                  li "#{ Post.count.to_s(:delimited) } products posted"
                  li "#{ Vote.for_posts.count.to_s(:delimited) } post votes cast"
                  li "#{ User.count.to_s(:delimited) } users"
                  li "#{ Comment.count.to_s(:delimited) } comments"
                  li "#{ Collection.count.to_s(:delimited) } collections"
                  li "#{ Products::ProductAssociation.count.to_s(:delimited) } associated products"
                end
              end
            end
          end
        end
      end
    end

    columns do
      column do
        panel 'Other admin sections' do
          ul do
            li link_to 'Product associations', admin_product_associations_path
            li link_to '[Legacy] Product links', admin_legacy_product_links_path
            li link_to 'Oauth Apps', admin_oauth_applications_path
            li link_to 'Unique Clickthroughs', admin_link_trackers_path
            li link_to 'GDPR Email delete', admin_gdpr_delete_email_path
            li link_to 'Marketing Notifications', admin_marketing_notifications_path
          end
        end

        panel 'DEVELOPER TOOLS' do
          ul do
            li link_to 'Mailers', '/rails/mailers'
            li link_to 'Mail test', admin_test_mailer_path
            li link_to 'Quick Mailjet test', admin_test_mailer_send_mailjet_test_path
            li link_to 'Activity Feed', admin_test_activity_feed_path
            li link_to 'Mobile Notifications', admin_test_mobile_notifications_path
          end
        end
      end
    end
  end
end
