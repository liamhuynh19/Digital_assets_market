require "image_processing/vips"
class ImageThumbnailJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find(product_id)
    return unless product.asset.attached? && product.asset.content_type.start_with?("image/")



    product.asset.open do |file|
      thumbnail = ImageProcessing::Vips
        .source(file)
        .resize_to_limit(300, 300)
        .convert("jpg")
        .call

      product.thumbnail.attach(
        io: thumbnail,
        filename: "#{product.id}_thumbnail.jpg",
        content_type: "image/jpeg"
      )
      product.update(status: "uploaded")
    end
  end
end
