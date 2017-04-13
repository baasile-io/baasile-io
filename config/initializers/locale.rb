# Where the I18n library should search for translation files
I18n.load_path += Dir[Rails.root.join('config', 'locale', '**/*.yml')]

I18n.config.available_locales = [:fr, :en]

I18n.default_locale = :en