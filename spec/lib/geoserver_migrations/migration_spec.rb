require 'spec_helper'
require 'fixtures/migrate_examples/migrate_1/01_first_migration'

RSpec.describe GeoserverMigrations::Migrator do

  context "running our first migration" do
    context "it collects the layers to be created" do
      before do
        @first_migration = FirstMigration.new
      end
      context "run it" do
        before do
          @first_migration.run
        end
        it "stores two layers" do
          expect(@first_migration.instance_variable_get("@layers_to_create").keys.sort).to eq([:settlement_gauges, :welds])
        end
        context "the welds layer" do
          before do
            @welds = @first_migration.instance_variable_get("@layers_to_create")[:welds]
          end
          # it "has set options" do
          #   expect(@welds.options.inspect).to eq("XXX")
          # end
          it "has an sld" do
            expect(@welds.style_name).to eq(:welds)
          end
        end
        context "the settlement-gauges layer" do
          before do
            @settlement_gauges = @first_migration.instance_variable_get("@layers_to_create")[:settlement_gauges]
          end
          # it "has set options" do
          #   expect(@settlement_gauges.options.inspect).to eq("XXX")
          # end
          it "has an sld" do
            expect(@settlement_gauges.sld).to eq("this is a test")
          end
          it "has an style-name" do
            expect(@settlement_gauges.style_name).to be nil
          end
          it "has an feature-name" do
            expect(@settlement_gauges.feature_name).to eq(:settlement_gauges)
          end
        end
        it "stores two layers" do
          expect(@first_migration.instance_variable_get("@layers_to_create").keys.sort).to eq([:settlement_gauges, :welds])
        end
      end
    end
  end

end
