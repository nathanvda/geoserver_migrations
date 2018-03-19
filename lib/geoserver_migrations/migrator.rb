module GeoserverMigrations

  class Migrator

    MigrationFilenameRegexp = /\A([0-9]+)_([_a-z0-9]*)\.?([_a-z0-9]*)?\.rb\z/

    def migrate
      if !any_migrations?
        puts "No migration files found!"
      else
        if !pending_migrations?
          puts "There are no pending migrations."
        else
          pending_migrations.each do |migration|
            migration.migrate
            
            GeoServerMigration.set_migrated(migration)
          end
        end
      end
    end


    def rollback(steps=1)
      if steps < 1
        puts "The nr of steps to rollback has to be at least 1"
      else
        rollback_migrations(steps).each do |migration|
          migration.migrate(:down)

          GeoServerMigration.set_reverted(migration)
        end
      end
    end



    def get_all_versions
      begin
        GeoserverMigration.all_versions.map(&:to_i)
      rescue
        []
      end
    end

    def current_version
      get_all_versions.max || 0
    end

    def needs_migration?
      (migrations(migrations_paths).collect(&:version) - get_all_versions).size > 0
    end

    def any_migrations?
      migrations(migrations_paths).any?
    end


    def rollback_migrations(steps=1)
      to_rollback = get_all_versions[0 - steps .. -1]
      migrations = migrations(migrations_paths)
      migrations.select { |m| to_rollback.include?(m.version) }
    end

    def pending_migrations
      already_migrated = get_all_versions
      migrations = migrations(migrations_paths)
      migrations.reject { |m| already_migrated.include?(m.version) }
    end


    def migrations_paths=(paths)
      @migrations_paths = paths
    end

    def migrations_paths
      @migrations_paths ||= ["geoserver/migrate"]
      # just to not break things if someone uses: migrations_path = some_string
      Array(@migrations_paths)
    end

    def parse_migration_filename(filename) # :nodoc:
      File.basename(filename).scan(MigrationFilenameRegexp).first
    end

    def migrations(paths)
      paths = Array(paths)

      migrations = migration_files(paths).map do |file|
        version, name, scope = parse_migration_filename(file)
        raise GeoserverMigrations::IllegalMigrationNameError.new(file) unless version
        version = version.to_i
        name = name.camelize

        MigrationProxy.new(name, version, file, scope)
      end

      migrations.sort_by(&:version)
    end

    def migration_files(paths)
      Dir[*paths.flat_map { |path| "#{path}/**/[0-9]*_*.rb" }]
    end


  end
end