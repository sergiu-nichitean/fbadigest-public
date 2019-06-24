desc "Send weekly newsletter"
task :send_weekly_newsletter => :environment do
  puts "Sending weekly newsletter"
  WeeklyNewsletterWorker.new.perform
  puts "done."
end