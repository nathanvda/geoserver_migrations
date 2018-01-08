class GeoserverMigration < ActiveRecord::Base

  self.primary_key = 'version'

  def self.all_versions
    order(:version).pluck(:version)
  end

  def self.set_migrated(migration)
    self.create!(version: migration.version.to_s)
  end

  def version
    super.to_i
  end

end