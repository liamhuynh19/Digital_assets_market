module LayoutHelper
  def body_class
    if controller_path.start_with?("devise/")
      "devise-page"
    else
      ""
    end
  end
end
