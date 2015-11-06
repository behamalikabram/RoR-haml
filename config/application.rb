require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DuelAllDay
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.autoload_paths += %W(#{config.root}/lib) # add this line
    config.action_mailer.delivery_method = :smtp

    config.action_mailer.smtp_settings = {
        address:              'smtp.mandrillapp.com',
        port:                 587,
        domain:               'duelallday.com',
        user_name:            ENV['MANDRILL_USERNAME'],
        password:             ENV['MANDRILL_PASSWORD'],
        authentication:       'plain',
        enable_starttls_auto: true  }

    config.assets.paths << Rails.root.join('app','assets','fonts')
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
