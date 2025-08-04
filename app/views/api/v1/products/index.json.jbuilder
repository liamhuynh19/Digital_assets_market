json.data do
  json.array! @products do |product|
    json.id product.id
    json.name product.name
    json.description product.description
    json.price product.price
    json.status product.status
    json.created_at product.created_at.iso8601
    json.updated_at product.updated_at.iso8601

    if product.asset.attached?
      json.asset_url rails_blob_url(product.asset, only_path: true)
    end

    if product.thumbnail.attached?
      json.thumbnail_url rails_blob_url(product.thumbnail, only_path: true)
    end

    if product.video_hd.attached?
      json.video_hd_url rails_blob_url(product.video_hd, only_path: true)
    end

    if product.video_full_hd.attached?
      json.video_full_hd_url rails_blob_url(product.video_full_hd, only_path: true)
    end

    if product.video_4k.attached?
      json.video_4k_url rails_blob_url(product.video_4k, only_path: true)
    end

    json.user do
      json.id product.user.id
      json.email product.user.email
      json.name product.user.name
    end

    json.category do
      json.id product.category.id
      json.name product.category.name
    end
  end
end
