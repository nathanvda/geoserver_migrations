require 'spec_helper'

RSpec.describe GeoserverMigrations::LayergroupConfig do

  context "valid?" do
    context "default layer-config" do
      it "is NOT valid when no layers given" do
        lc = GeoserverMigrations::LayergroupConfig.new("test")
        expect(lc.valid?).to eq(false)
      end
    end
    context "adding some layers" do
      it "is valid" do
        lc = GeoserverMigrations::LayergroupConfig.new("test")
        lc.layers "sabic:pipelines, sabic:cables"
        expect(lc.valid?).to eq(true)
      end
    end

  end

end
