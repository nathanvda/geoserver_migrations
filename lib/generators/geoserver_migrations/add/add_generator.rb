module GeoserverMigrations
  module Generators
    class AddGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      desc "Adds an empty named migration"

      def add_migration
        migration_name = file_name.underscore
        class_name = file_name.camelize

        create_file File.join(Rails.root, GeoserverMigrations.migrations_rootpath, "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{migration_name}.rb"), <<-MIGRATION_FILE
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