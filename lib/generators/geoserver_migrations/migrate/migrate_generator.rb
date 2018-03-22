module GeoserverMigrations
  module Generators
    class MigrateGenerator < ::Rails::Generators::Base
      desc "Check and run the needed geoserver migrations"

      def run_migrations
        migrator = GeoserverMigrations::Migrator.new
        migrator.migrations_paths = GeoserverMigrations.migrations_rootpath
        migrator.migrate
      end

    end
  end
end