module GeoserverMigrations
  module Generators
    class MigrateGenerator < ::Rails::Generators::Base
      desc "Check and run the needed geoserver migrations"

      def run_migrations
        puts "Run migrations ... "
      end

    end
  end
end