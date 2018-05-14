module GeoserverMigrations
  module Generators
    class RollbackGenerator < ::Rails::Generators::Base
      desc "Rollback the last geoserver migrations"

      def rollback_migrations
        migrator = GeoserverMigrations::Migrator.new
        migrator.migrations_paths = GeoserverMigrations.migrations_rootpath
        migrator.rollback
      end

    end
  end
end