desc "Generate post slugs"
task :generate_post_slugs => :environment do
  puts "Generating post slugs"
  GeneratePostSlugsWorker.new.perform
  puts "done."
end