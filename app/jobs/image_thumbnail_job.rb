require "streamio-ffmpeg"

class ImageThumbnailJob < ApplicationJob
  queue_as :media

  def perform(product_id)
    product = Product.find(product_id)
    return unless product.asset.attached? && product.asset.content_type.start_with?("image/")

    product.asset.open do |file|
      thumbnail_path = Rails.root.join("tmp", "#{product.id}_thumbnail.jpg").to_s
      create_thumbnail_with_ffmpeg(file.path, thumbnail_path)

      product.thumbnail.attach(
        io: File.open(thumbnail_path),
        filename: "#{product.id}_thumbnail.jpg",
        content_type: "image/jpeg"
      )

      preview_path = Rails.root.join("tmp", "#{product.id}_preview.jpg").to_s
      create_watermarked_preview_with_ffmpeg(file.path, preview_path)

      product.preview.attach(
        io: File.open(preview_path),
        filename: "#{product.id}_preview.jpg",
        content_type: "image/jpeg"
      )

      product.update(status: "uploaded")

      File.delete(thumbnail_path) if File.exist?(thumbnail_path)
      File.delete(preview_path) if File.exist?(preview_path)
    end

  rescue StandardError => e
    Rails.logger.error "Failed to process image for product #{product.id}: #{e.message}"
    product.update(status: "failed") if product
    raise e
  end

  private

  def create_thumbnail_with_ffmpeg(input_path, output_path)
    movie = FFMPEG::Movie.new(input_path)
    movie.transcode(output_path, [
      "-vf", "scale=300:300:force_original_aspect_ratio=decrease",
      "-q:v", "2"
    ])
  end

  def create_watermarked_preview_with_ffmpeg(input_path, output_path)
    movie = FFMPEG::Movie.new(input_path)
    watermark_text = "Digital Assets Market"

    watermark_filter = watermark_filter_for_image(watermark_text)

    movie.transcode(output_path, [
      "-vf", "scale=800:600:force_original_aspect_ratio=decrease,#{watermark_filter}",
      "-q:v", "2"
    ])
  end

  def watermark_filter_for_image(text = "Digital Assets Market")
    escaped_text = text.gsub("'", "\\\\'").gsub('"', '\\"')
    "drawtext=text='#{escaped_text}':fontcolor=white@0.7:fontsize=64:x=(w-text_w)/2:y=(h-text_h)/2:shadowcolor=black@0.8:shadowx=4:shadowy=4:box=1:boxcolor=black@0.5:boxborderw=16"
  end
end
