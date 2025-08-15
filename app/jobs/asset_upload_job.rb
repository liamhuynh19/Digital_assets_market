require "streamio-ffmpeg"

class AssetUploadJob < ApplicationJob
  queue_as :media
  private

  def watermark_filter(text = "Digital Assets Market")
    escaped_text = text.gsub("'", "\\\\'").gsub('"', '\\"')
    "drawtext=text='#{escaped_text}':fontcolor=white@0.7:fontsize=64:x=(w-text_w)/2:y=(h-text_h)/2:shadowcolor=black@0.8:shadowx=4:shadowy=4:box=1:boxcolor=black@0.5:boxborderw=16"
  end

  def create_watermarked_video(movie, output_path, scale_filter, watermark_text)
    combined_filter = "#{scale_filter},#{watermark_filter(watermark_text)}"
    movie.transcode(output_path, [ "-vf", combined_filter, "-c:v", "libx264", "-preset", "medium", "-crf", "23" ])
  end

  def perform(product_id)
    product = Product.find(product_id)
    return unless product&.asset&.video?

    product.asset.open do |file|
      movie = FFMPEG::Movie.new(file.path)
      watermark_text = "Digital Assets Market"

      # Thumbnail
      temp_thumbnail_path = Rails.root.join("tmp", "#{product.id}_thumbnail.jpg").to_s
      movie.screenshot(temp_thumbnail_path, seek_time: 1)
      product.thumbnail.attach(io: File.open(temp_thumbnail_path), filename: "#{product.id}_thumbnail.jpg", content_type: "image/jpeg")
      File.delete(temp_thumbnail_path) if File.exist?(temp_thumbnail_path)

      # Preview
      preview_path = Rails.root.join("tmp", "#{product.id}_preview.mp4").to_s
      create_watermarked_video(movie, preview_path, "scale=1080:720", watermark_text)
      product.preview.attach(io: File.open(preview_path), filename: "#{product.id}_preview.mp4", content_type: "video/mp4")
      File.delete(preview_path) if File.exist?(preview_path)

      # HD Ready 1080x720
      hd_path = Rails.root.join("tmp", "#{product.id}_hd_ready.mp4").to_s
      movie.transcode(hd_path, %w[-vf scale=1080:720])
      product.video_hd.attach(io: File.open(hd_path), filename: "#{product.id}_hd_ready.mp4", content_type: "video/mp4")
      File.delete(hd_path) if File.exist?(hd_path)

      # Full HD 1920x1080
      full_hd_path = Rails.root.join("tmp", "#{product.id}_full_hd.mp4").to_s
      movie.transcode(full_hd_path, %w[-vf scale=1920:1080])
      product.video_full_hd.attach(io: File.open(full_hd_path), filename: "#{product.id}_full_hd.mp4", content_type: "video/mp4")
      File.delete(full_hd_path) if File.exist?(full_hd_path)

      # 4K 4096x2160
      four_k_path = Rails.root.join("tmp", "#{product.id}_4k.mp4").to_s
      movie.transcode(four_k_path, %w[-vf scale=4096:2160])
      product.video_4k.attach(io: File.open(four_k_path), filename: "#{product.id}_4k.mp4", content_type: "video/mp4")
      File.delete(four_k_path) if File.exist?(four_k_path)

      product.update(status: "uploaded")
    end

  rescue StandardError => e
    Rails.logger.error "Failed to process video upload for product ##{product.id}: #{e.message}"
  end
end
