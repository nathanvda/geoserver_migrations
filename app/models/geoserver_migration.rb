class GeoserverMigration < ActiveRecord::Base

  self.primary_key = 'version'

  def self.all_versions
    order(:version).pluck(:version)
  end

  def version
    super.to_i
  end

end