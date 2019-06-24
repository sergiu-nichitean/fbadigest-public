desc "Fetch external posts"
task :fetch_external_posts => :environment do
  puts "Fetching External posts"
  FetchExternalPostsWorker.new.perform
  puts "done."
end