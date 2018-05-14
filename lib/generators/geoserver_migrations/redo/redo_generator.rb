module GeoserverMigrations
  module Generators
    class RedoGenerator < ::Rails::Generators::Base
      desc "Redo the last geoserver migrations"

      def rollback_migrations
        migrator = GeoserverMigrations::Migrator.new
        migrator.migrations_paths = GeoserverMigrations.migrations_rootpath
        # there should not be any pending migrations!
        if migrator.needs_migration?
          puts "There are pending migrations! We can only redo the last migration if there are no pending migrations."
        else
          migrator.rollback
          migrator.migrate
        end
      end

    end
  end
end