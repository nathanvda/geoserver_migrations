require 'spec_helper'

RSpec.describe GeoserverMigration do

  describe ".all_versions" do
    it "exists" do
      expect(GeoserverMigration.respond_to?(:all_versions)).to be true
    end
    it "lists all versions" do
      GeoserverMigration.create!(version: 1)
      GeoserverMigration.create!(version: 2)
      expect(GeoserverMigration.all_versions).to eq(["1","2"])
    end
  end

end