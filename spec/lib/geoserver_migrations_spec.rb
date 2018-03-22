require 'spec_helper'

RSpec.describe GeoserverMigrations do

  context "migrations_rootpath" do

    it "returns the default value if nothing is configured" do
      expect(GeoserverMigrations.migrations_rootpath).to eq("geoserver/migrate")
    end
    
    it "returns the configured value" do
      GEOSERVER_MIGRATIONS_CONFIG[:migrations_path] = "XXX"
      expect(GeoserverMigrations.migrations_rootpath).to eq("XXX")
    end

  end
end
