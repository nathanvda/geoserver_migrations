module GeoserverMigrations
  module Generators
    class MigrateGenerator < ::Rails::Generators::Base
      desc "Check and run the needed geoserver migrations"

      def run_migrations
        migrator = GeoserverMigrations::Migrator.new
        migrator.migrations_paths = GEOSERVER_MIGRATIONS_CONFIG[:migrations_path]
        migrator.migrate
      end

    end
  end
end