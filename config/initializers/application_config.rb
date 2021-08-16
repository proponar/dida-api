if Rails.env == 'development'
  Rails.application.config.public = true
elsif Rails.env == 'public'
  Rails.application.config.public = true
else
  Rails.application.config.public = false
end
