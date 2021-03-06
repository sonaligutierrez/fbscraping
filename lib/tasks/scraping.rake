namespace :scraping do

  desc "Run all post scraping"
  task start: :environment do
    Post.all.each do |post|
      begin
        puts "Proccesing: #{post.title} (#{post.id})"
        count = post.scraping
        puts "Procesados: #{count} comments"
      rescue Exception => e
        puts e.message
      end
    end
  end

  desc "Run all post scraping with watir"
  task start_watir: :environment do
    Post.all.limit(20).each do |post|
      begin
        puts "Proccesing: #{post.title} (#{post.id})"
        count = post.scraping_watir
        puts "Procesados: #{count} comments"
      rescue Exception => e
        puts e.message
      end
    end
  end

  desc "Run all post scraping asincronaly"
  task async_start: :environment do
    Post.created_before_24_hours.each do |post|
      begin
        puts "Programming: #{post.title} (#{post.id})"
        count = ExtractDataInBatchJob.set(wait: 1.second).perform_later post
      rescue Exception => e
        puts e.message
        Rollbar.error(e.message)
      end
    end
  end

  desc "Run all post scraping asincronaly"
  task async_watir_start: :environment do
    Post.created_before_24_hours.each do |post|
      begin
        puts "Programming: #{post.title} (#{post.id})"
        count = ExtractDataWatirInBatchJob.set(wait: 1.second).perform_later post
      rescue Exception => e
        puts e.message
        Rollbar.error(e.message)
      end
    end
  end

  desc "Run all facebook user profile scraping asincronaly"
  task async_facebook_users_start: :environment do
    FacebookUser.created_before_24_hours.all.each do |profile|
      begin
        if profile.fb_avatar.to_s.empty?
          puts "Programming: #{profile.name} (#{profile.id})"
          count = ExtractProfileDataInBatchJob.set(wait: 1.second).perform_later profile
        end
      rescue Exception => e
        puts e.message
        Rollbar.error(e.message)
      end
    end
  end

end
