module GeoserverMigrations
  module Generators
    class AddGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      desc "Adds an empty named migration"

      def add_migration
        migration_name = file_name.underscore
        class_name = file_name.camelize

        migrations_rootpath = GEOSERVER_MIGRATIONS_CONFIG[:migrations_path]
        migrations_rootpath ||= 'geoserver/migrate'

        create_file File.join(Rails.root, migrations_rootpath, "#{migration_name}.rb"), <<-MIGRATION_FILE
class #{class_name} < GeoserverMigrations::Migration

  def run 
    # add migration code here
  end 

end
MIGRATION_FILE
        
      end

    end
  end
end