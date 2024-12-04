if ENV['CLOUDINARY_URL'].present?
  Cloudinary.config do |config|
    config.cloud_name = "diugmcj6k"
    config.api_key = "589325238212739"
    config.api_secret = "rKwpNiHAFvzqRjuqoRsuQQa72LA"
    config.secure = true
  end
else
  puts "WARNING: Cloudinary configuration is missing"
end
