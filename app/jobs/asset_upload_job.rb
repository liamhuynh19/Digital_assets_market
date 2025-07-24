require "streamio-ffmpeg"
class AssetUploadJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find(product_id)
    return unless product&.asset&.video?
    puts "Processing asset upload for product #{product.id}"
    product.asset.open do |file|
      movie = FFMPEG::Movie.new(file.path)
      temp_thumbnail_path = Rails.root.join("tmp", "#{product.id}_thumbnail.jpg").to_s
      movie.screenshot(temp_thumbnail_path, seek_time: 1)

      product.thumbnail.attach(io: File.open(temp_thumbnail_path), filename: "#{product.id}_thumbnail.jpg", content_type: "image/jpeg")
      puts "Thumbnail created and attached for product ##{product.id}"
      File.delete(temp_thumbnail_path) if File.exist?(temp_thumbnail_path)
      product.update(status: "uploaded")
    end

  rescue StandardError => e
    Rails.logger.error "Failed to process thumbnail upload for product ##{product.id}: #{e.message}"
  end
end
