json.data do
  json.product do
    json.extract! @product, :id, :name, :description, :price, :status, :created_at, :updated_at
    json.category do
      if @product.category.present?
        json.extract! @product.category, :id, :name
      else
        json.null!
      end
    end

    json.seller do
      if @product.user.present?
        json.extract! @product.user, :id, :email, :name
      else
        json.null!
      end
    end

    json.media do
      json.content_type @product.asset.content_type
      json.thumbnail @product.thumbnail.attached? ? rails_blob_url(@product.thumbnail) : nil
      json.asset @product.asset.attached? ? rails_blob_url(@product.asset) : nil
      if @product.asset.content_type == "video/mp4"
        json.video_hd @product.video_hd.attached? ? rails_blob_url(@product.video_hd) : nil
        json.video_full_hd @product.video_full_hd.attached? ? rails_blob_url(@product.video_full_hd) : nil
        json.video_4k @product.video_4k.attached? ? rails_blob_url(@product.video_4k) : nil
      end
    end
  end
end
