class GeneratePostSlugsWorker
  
  def perform
  	Post.where('slug IS NULL').each do |post|
  		slug = Post.get_unique_slug(post)
  		puts "Slug for post with ID #{post.id}: #{slug}"
  		post.update(slug: slug)
  	end
  end

end