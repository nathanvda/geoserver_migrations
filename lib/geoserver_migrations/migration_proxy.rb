module GeoserverMigrations

  # MigrationProxy is used to defer loading of the actual migration classes
  # until they are needed
  MigrationProxy = Struct.new(:name, :version, :filename, :scope) do
    def initialize(name, version, filename, scope)
      super
      @migration = nil
    end

    def basename
      File.basename(filename)
    end

    def mtime
      File.mtime filename
    end

    delegate :migrate, to: :migration

    private

    def migration
      @migration ||= load_migration
    end

    def load_migration
      require(File.expand_path(filename))
      name.constantize.new(name, version)
    end
  end

end