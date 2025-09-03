Rails.application.config.to_prepare do
  ActionMailer::Base.class_eval do
    # Add support for the singular form by redirecting to the plural form
    def self.preview_path=(path)
      self.preview_paths = [ path ]
    end
  end
end
