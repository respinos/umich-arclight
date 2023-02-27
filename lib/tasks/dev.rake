namespace :dev do
  desc "Use custom error pages"
  task errors: :environment do
    if File.exist?("tmp/errors-dev.txt")
      puts "Using default (development) error pages" if FileUtils.rm("tmp/errors-dev.txt")
    elsif FileUtils.touch("tmp/errors-dev.txt")
      puts "Using custom error pages"
    end
  end
end
