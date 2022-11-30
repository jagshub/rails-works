# frozen_string_literal: true

module Products
  extend self

  def admin_associate_posts_form
    Products::Admin::AssociatePostsForm
  end

  def admin_import_url_form
    Products::Admin::ImportUrlForm
  end

  def new_launch_update_with_throttle(post)
    Products::NewLaunchUpdateWithThrottle.new(post)
  end

  def admin_search_possible_posts(product)
    {
      same_link: Products::Posts.search_with_same_link(product),
      same_link_prefix: Products::Posts.search_with_link_prefix(product),
      same_name: Products::Posts.search_with_same_name(product),
    }
  end

  def ios_url(product)
    ::Products::PlatformUrl.find(product, :ios)
  end

  def android_url(product)
    ::Products::PlatformUrl.find(product, :android)
  end

  def set_product_state(product)
    ::Products::SetProductState.call(product)
  end

  def mark_as_offline(product)
    ::Products::SetProductState.mark_as_offline(product)
  end
end
