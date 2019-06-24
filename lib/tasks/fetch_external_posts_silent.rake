desc "Fetch external posts (no notifications)"
task :fetch_external_posts_silent => :environment do
  puts "Fetching External posts (no notifications)"
  FetchExternalPostsWorker.new.perform(true)
  puts "done."
end