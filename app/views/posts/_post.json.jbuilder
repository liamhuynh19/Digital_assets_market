json.extract! post, :id, :title, :creator, :description, :published_date, :created_at, :updated_at
json.url post_url(post, format: :json)
