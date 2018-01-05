class CreateGeoserverMigrations < ActiveRecord::Migration
  def change
    create_table :geoserver_migrations, id: false do |t|
      t.string :version
    end
    add_index :geoserver_migrations, :version, unique: true  
  end
end
