module GeoserverMigrations
  module Generators
    class StatusGenerator < ::Rails::Generators::Base
      desc "Verify geoserver-migrations is setup correctly"

      def check_status
        puts "Checking configuration ... "
        errors = []
        errors << "geoserver_base is not set" unless GeoserverMigrations.config[:geoserver_base].present?
        errors << "api-user is not set" unless       GeoserverMigrations.config[:api][:user].present?
        errors << "api-password is not set" unless GeoserverMigrations.config[:api][:password].present?

        errors << "Geoserver workspace is not set" unless GeoserverMigrations.config[:workspace].present?
        errors << "Geoserver datastore is not set" unless GeoserverMigrations.config[:datastore].present?

        unless errors.count > 0
          puts " --> Configuration ok"
        else
          puts "Problems with the configuration-file:\n #{errors.join("\n")}"
          puts "Check the documentation how to fix them"
          puts "Did you forget to edit the default config-file or to run rails g geoserver_migrations:install ?"
        end

        puts "Checking API reachability"
        begin
          layers = GeoserverMigrations::Base.connection.test
          puts " --> Connected to API correctly and retrieved #{layers.count} layers"
        rescue => e
          puts "    FAILED to reach Geoserver REST API."
          puts "    Error: #{e.message}"
        end

        puts "Checking database setup"
        begin
          count = GeoserverMigration.all_versions.count
          puts " --> Database is correctly setup"
        rescue => e
          puts "    Database is not setup correctly. Did you run rake db:migrate ?"
          puts "    The returned error is #{e.message}"
        end

        migrator = GeoserverMigrations::Migrator.new
        if migrator.needs_migration?
          puts "There are pending migrations."
        else
          puts "There are no pending migrations. Geoserver is up to date."
        end

      end

    end
  end
end