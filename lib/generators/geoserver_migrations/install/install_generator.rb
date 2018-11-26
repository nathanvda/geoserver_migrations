module GeoserverMigrations
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc "This generator installs the default config file, and glue code into application-controller; which you can edit"


      def copy_config_file
        copy_file "geoserver_migrations_config.yml", "config/geoserver_migrations_config.yml"
      end

      def create_migrations_folder
        # empty_directory "geoserver", "migrate"
        empty_directory "geoserver/migrate"
        empty_directory "geoserver/migrate/assets"
      end

    end
  end
end