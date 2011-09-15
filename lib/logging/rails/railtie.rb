
module Logging::Rails

  #
  #
  class Railtie < Rails::Railtie

    generators do
      require File.expand_path('../generators/install_generator', __FILE__)
    end

    config.before_configuration do
      config.log_to = %w[file]
    end

    initializer 'logging.configure', :before => 'initialize_logger' do |app|
      file = Rails.root.join('config/logging.rb')
      load file if File.exists? file
      ::Logging::Rails.configuration.call app.config if ::Logging::Rails.configuration
    end

    initializer 'logging.initialize', :before => 'initialize_logger' do
      Rails.logger = ::Logging::Logger[Rails]
    end

    initializer 'logging.active_record.logger', :before => 'active_record.logger' do
      ActiveSupport.on_load(:active_record) { self.logger = ::Logging::Logger[self] }
    end

    initializer 'logging.action_controller.logger', :before => 'action_controller.logger' do
      ActiveSupport.on_load(:action_controller) { self.logger = ::Logging::Logger[self] }
    end

    initializer 'logging.action_mailer.logger', :before => 'action_mailer.logger' do
      ActiveSupport.on_load(:action_mailer) { self.logger = ::Logging::Logger[self] }
    end

    initializer 'logging.active_support.dependencies.logger' do
      ActiveSupport::Dependencies.logger = ::Logging::Logger[ActiveSupport::Dependencies]
    end

    initializer 'logging.initialize_cache', :after => 'initialize_cache' do
      Rails.cache.logger = ::Logging::Logger[Rails.cache]
    end

    config.after_initialize do
      ::Logging.show_configuration if ::Logging::Logger[Rails].debug?
    end

  end  # Railtie
end  # Logging::Rails

