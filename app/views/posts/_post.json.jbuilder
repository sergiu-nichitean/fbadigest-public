json.extract! post, :id, :title, :content, :slug, :category_id, :source_id, :external_url, :post_tag_id, :image_url, :created_at, :updated_at
json.url post_url(post, format: :json)
