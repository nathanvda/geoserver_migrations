require 'geoserver_migrations/migration_proxy'
require 'geoserver_migrations/migration'
require 'geoserver_migrations/migrator'
require 'geoserver_migrations/base'
require 'geoserver_migrations/test_connector'
require 'geoserver_migrations/api_connector'
require 'geoserver_migrations/layer_config'


module GeoserverMigrations

  #define exceptions

  module ExceptionsMixin
    def initialize(str)
      super("GeoserverMigrations: " + str)
    end
  end
  class ArgumentError < ::ArgumentError #:nodoc:
    include ExceptionsMixin
  end

  class IllegalMigrationNameError < StandardError #:nodoc:
    include ExceptionsMixin
    def initialize(name = nil)
      if name
        super("Illegal name for migration file: #{name}\n\t(only lower case letters, numbers, and '_' allowed).")
      else
        super("Illegal name for migration.")
      end
    end
  end

  # class AccessDenied < ::StandardError #:nodoc:
  #   include ExceptionsMixin
  #   def initialize(str='Access denied: you do not have the right permissions for the requested action.')
  #     super(str)
  #   end
  # end


  class Engine < ::Rails::Engine

    # configure our plugin on boot
    initializer "geoserver_migrations.initialize" do |app|

      # mixin our code ?
      # ActionController::Base.send(:include, Vigilante::ControllerExtension)
      # ActiveRecord::Base.send(:include, Vigilante::ActiveRecordExtensions)

      #load configuration files if they are available
      geoserver_config_file         = File.join("#{Rails.root.to_s}", 'config', 'geoserver_migrations_config.yml')

      if File.exist?(geoserver_config_file)
        Rails.logger.debug "define GEOSERVER_MIGRATIONS_CONFIG"
        raw_config = File.read(geoserver_config_file)
        ::GEOSERVER_MIGRATIONS_CONFIG = YAML.load(raw_config)["#{Rails.env}"]
      # else
      #   raise GeoserverMigrations::ArgumentError.new("The geoserver_migrations_config.yml is missing. Path=#{geoserver_config_file} Did you run the generator geoserver_migrations:install? ")
      end
    end

    initializer :append_migrations do |app|
      unless app.root.to_s == root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end

    end

  end


end
