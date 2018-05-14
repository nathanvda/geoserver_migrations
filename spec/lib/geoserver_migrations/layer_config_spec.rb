require 'spec_helper'

RSpec.describe GeoserverMigrations::LayerConfig do

  context "valid?" do
    context "default layer-config" do
      it "is valid when a feature-name is given" do
        lc = GeoserverMigrations::LayerConfig.new("test")
        lc.options[:feature_name] = 'Some-feature'
        expect(lc.valid?).to eq(true)
      end
    end
    
  end

end
