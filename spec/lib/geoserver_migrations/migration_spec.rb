require 'spec_helper'
require 'fixtures/migrate_examples/migrate_1/01_first_migration'
require 'fixtures/migrate_examples/migrate_with_icon/05_add_icon'

RSpec.describe GeoserverMigrations::Migration do

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
          it "has set options" do
            expect(@welds.options.inspect).to eq("{:layer_name=>:welds, :is_update_style=>false, :style_name=>:welds, :feature_name=>:welds}")
          end
          it "has an sld" do
            expect(@welds.style_name).to eq(:welds)
          end
        end
        context "the settlement-gauges layer" do
          before do
            @settlement_gauges = @first_migration.instance_variable_get("@layers_to_create")[:settlement_gauges]
          end
          it "has set options" do
            expect(@settlement_gauges.options.inspect).to eq("{:layer_name=>:settlement_gauges, :is_update_style=>false, :sld=>\"this is a test\", :feature_name=>:settlement_gauges}")
          end
          it "has an sld" do
            expect(@settlement_gauges.sld).to eq("this is a test")
          end
          it "returns the layer-name as style-name" do
            expect(@settlement_gauges.style_name).to eq(:settlement_gauges)
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

  context ".migrate" do
    context "it collects the layers to be created and performs the migration" do
      before do
        @test_connector = GeoserverMigrations::TestConnector.new
        GeoserverMigrations::Base.connection = @test_connector
        @first_migration = FirstMigration.new
      end
      it "test-prepararion has correctly set the base connector" do
        expect(GeoserverMigrations::Base.connection.class.name).to eq("GeoserverMigrations::TestConnector")
      end

      context "run it" do
        before do
          @first_migration.migrate
        end
        it "has collected the layers" do
          expect(@test_connector.collected_actions[:up].map{|x| x[:params][:name]}.sort).to eq([:settlement_gauges, :welds])
        end
        # it "stores two layers" do
        #   expect(@first_migration.instance_variable_get("@layers_to_create").keys.sort).to eq([:settlement_gauges, :welds])
        # end
        # context "the welds layer" do
        #   before do
        #     @welds = @first_migration.instance_variable_get("@layers_to_create")[:welds]
        #   end
        #   it "has set options" do
        #     expect(@welds.options.inspect).to eq("{:style_name=>:welds, :feature_name=>:welds}")
        #   end
        #   it "has an sld" do
        #     expect(@welds.style_name).to eq(:welds)
        #   end
        # end
        # context "the settlement-gauges layer" do
        #   before do
        #     @settlement_gauges = @first_migration.instance_variable_get("@layers_to_create")[:settlement_gauges]
        #   end
        #   it "has set options" do
        #     expect(@settlement_gauges.options.inspect).to eq("{:sld=>\"this is a test\", :feature_name=>:settlement_gauges}")
        #   end
        #   it "has an sld" do
        #     expect(@settlement_gauges.sld).to eq("this is a test")
        #   end
        #   it "has an style-name" do
        #     expect(@settlement_gauges.style_name).to be nil
        #   end
        #   it "has an feature-name" do
        #     expect(@settlement_gauges.feature_name).to eq(:settlement_gauges)
        #   end
        # end
        it "stores two layers" do
          expect(@first_migration.instance_variable_get("@layers_to_create").keys.sort).to eq([:settlement_gauges, :welds])
        end
      end
      context "rolling back" do
        before do
          @first_migration.migrate(:down)
        end
        it "has collected the layers" do
          expect(@test_connector.collected_actions[:down].map{|x| x[:params][:name]}.sort).to eq([:settlement_gauges, :welds])
        end
        it "stores two layers" do
          expect(@first_migration.instance_variable_get("@layers_to_create").keys.sort).to eq([:settlement_gauges, :welds])
        end
      end
    end
  end

  context "adding a resource" do
    before do
      @icon_migration = AddIcon.new
    end
    context "with incorrect settings or missing assets" do
      before do
        @icon_migration.asset_path = 'spec/fixtures/migrate_examples/migrate_with_icon/assets_NOT'
      end
      it "will raise an exception" do
        expect {
          @icon_migration.run
        }.to raise_error(StandardError)
        # }.to raise_error(StandardError, "File /Users/nathan/work/git/geoserver_migrations/spec/fixtures/migrate_examples/migrate_with_icon/assets_NOT/deer.png not found!")
      end
    end

    context "it will collect the actions to add resources" do
      before do
        @icon_migration.asset_path = 'spec/fixtures/migrate_examples/migrate_with_icon/assets'
        @icon_migration.run
      end
      it "has added 1 action to take" do
        expect(@icon_migration.instance_variable_get('@ordered_actions_to_take').count).to eq(1)
      end
      context "the added action" do
        before do
          @add_icon_action = @icon_migration.instance_variable_get('@ordered_actions_to_take').first
        end
        it "has the correct action-type" do
          expect(@add_icon_action[:action]).to eq(:add_resource)
        end
        it "has the correct name as param" do
          expect(@add_icon_action[:params][:name]).to end_with("spec/fixtures/migrate_examples/migrate_with_icon/assets/deer.png")
        end
      end
    end
  end
end
