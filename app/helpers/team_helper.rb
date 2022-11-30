# frozen_string_literal: true

module TeamHelper
  def user_link(user)
    link_to user.name, Routes.profile_url(user)
  end

  def product_link(product)
    link_to product.name, Routes.product_url(product)
  end

  def support_mail_link
    link_to 'support@producthunt.com', 'mailto:support@producthunt.com'
  end
end
