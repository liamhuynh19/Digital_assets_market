module ProductsHelper
  def display_original_asset?(current_user, product)
    current_user && (current_user.has_role?("admin") ||
    (current_user.has_role?("seller") && product.user == current_user)) ||
    product.purchased_by?(current_user)
  end
end
