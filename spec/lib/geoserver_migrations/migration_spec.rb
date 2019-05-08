require 'spec_helper'
require 'fixtures/migrate_examples/migrate_1/01_first_migration'
require 'fixtures/migrate_examples/migrate_with_icon/05_add_icon'
require 'fixtures/migrate_examples/migrate_with_icon/06_sld_helpers_tester'
require 'fixtures/migrate_examples/migrate_with_icon/07_add_a_layergroup'

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
        @icon_migration.assets_path = 'spec/fixtures/migrate_examples/migrate_with_icon/assets_NOT'
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
        @icon_migration.assets_path = 'spec/fixtures/migrate_examples/migrate_with_icon/assets'
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


  context "using the SLD helpers" do
    before do
      @sld_helper_migration = SldHelpersTester.new
    end

    context "it will collect the actions to add resources" do
      before do
        @sld_helper_migration.assets_path = 'spec/fixtures/migrate_examples/migrate_with_icon/assets'
        @sld_helper_migration.run
      end
      it "stores two layers" do
        expect(@sld_helper_migration.instance_variable_get("@layers_to_create").keys.sort).to eq([:alt_deers, :alt_moose, :blackbirds, :deers, :mice, :moose, :toads])
      end
      it "has added 5 actions to take (layers and 1 icon)" do
        expect(@sld_helper_migration.instance_variable_get('@ordered_actions_to_take').count).to eq(8)
      end

      context "the alt-deers layer" do
        before do
          @alt_deers = @sld_helper_migration.instance_variable_get("@layers_to_create")[:alt_deers]
        end
        it "has set the style-name" do
          expect(@alt_deers.style_name).to eq(:alt_deers)
        end
        it "has set the feature-name" do
          expect(@alt_deers.feature_name).to eq(:deers)
        end
        it "has filled the correct sld" do
          sld_with_filter = <<-SLD.strip_heredoc
            <?xml version="1.0" encoding="UTF-8"?>
            <StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
              xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
              <NamedLayer>
                <Name>ALT DEERS</Name>
                <UserStyle>
                  <Name>ALT DEERS</Name>
                  <Title>ALT DEERS</Title>
                  <Abstract>ALT DEERS</Abstract>
                  <FeatureTypeStyle>
                    <Rule>
                      <Title>Lieve hertjes</Title>
                      <ogc:Filter>
                        <ogc:PropertyIsEqualTo>
                          <ogc:PropertyName>active</ogc:PropertyName>
                          <ogc:Literal>true</ogc:Literal>
                        </ogc:PropertyIsEqualTo>
                      </ogc:Filter>
                      <MaxScaleDenominator>15000</MaxScaleDenominator>
                      <PointSymbolizer>
                        <Graphic>
                          <ExternalGraphic>
                            <OnlineResource xlink:type="simple" xlink:href="deer_with_hart.png" />
                            <Format>image/png</Format>
                          </ExternalGraphic>
                        </Graphic>
                        <VendorOption name="labelObstacle">true</VendorOption>
                      </PointSymbolizer>
                      <TextSymbolizer>
                        <Label>
                          <ogc:PropertyName>name</ogc:PropertyName>
                        </Label>
                        <Font>
                          <CssParameter name="font-family">Arial</CssParameter>
                          <CssParameter name="font-size">11</CssParameter>
                          <CssParameter name="font-style">normal</CssParameter>
                          <CssParameter name="font-weight">bold</CssParameter>
                        </Font>
                        <LabelPlacement>
                          <PointPlacement>
                            <AnchorPoint>
                              <AnchorPointX>0</AnchorPointX>
                              <AnchorPointY>0</AnchorPointY>
                            </AnchorPoint>
                          </PointPlacement>
                        </LabelPlacement>
                        <Halo>
                          <Radius>
                            <ogc:Literal>1</ogc:Literal>
                          </Radius>
                          <Fill>
                            <CssParameter name="fill">#ffffff</CssParameter>
                          </Fill>
                        </Halo>
                        <Fill>
                          <CssParameter name="fill">#2f3133</CssParameter>
                        </Fill>
                        <VendorOption name="maxDisplacement">40</VendorOption>
                        <!--VendorOption name="displacementMode">S, SW, W, NW, N</VendorOption-->
                        <VendorOption name="conflictResolution">true</VendorOption>
                        <VendorOption name="partials">true</VendorOption>
                      </TextSymbolizer>
                    </Rule>
                  </FeatureTypeStyle>
                </UserStyle>
              </NamedLayer>
            </StyledLayerDescriptor>

          SLD
          expect(@alt_deers.sld).to match_fuzzy(sld_with_filter)
        end
      end
      context "the deers layer" do
        before do
          @deers = @sld_helper_migration.instance_variable_get("@layers_to_create")[:deers]
        end
        it "has set layer-name" do
          expect(@deers.layer_name).to eq(:deers)
        end
        it "has set the style-name" do
          expect(@deers.style_name).to eq(:deers)
        end
        it "has an sld" do
          resulting_sld = <<-SLD.strip_heredoc
          <?xml version="1.0" encoding="UTF-8"?>
          <StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
            xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
            <NamedLayer>
              <Name>Deers</Name>
              <UserStyle>
                <Name>Deers</Name>
                <Title>Deers</Title>
                <Abstract>Deers</Abstract>
                <FeatureTypeStyle>
                  <Rule>
                    <Title>Deers</Title>
  
  
                    <PointSymbolizer>
                      <Graphic>
                        <ExternalGraphic>
                          <OnlineResource xlink:type="simple" xlink:href="deer.png" />
                          <Format>image/png</Format>
                        </ExternalGraphic>
                      </Graphic>
                      <VendorOption name="labelObstacle">true</VendorOption>
                    </PointSymbolizer>
                    <TextSymbolizer>
                      <Label>
                        <ogc:PropertyName>name</ogc:PropertyName>
                      </Label>
                      <Font>
                        <CssParameter name="font-family">Arial</CssParameter>
                        <CssParameter name="font-size">11</CssParameter>
                        <CssParameter name="font-style">normal</CssParameter>
                        <CssParameter name="font-weight">bold</CssParameter>
                      </Font>
                      <LabelPlacement>
                        <PointPlacement>
                          <AnchorPoint>
                            <AnchorPointX>0</AnchorPointX>
                            <AnchorPointY>0</AnchorPointY>
                          </AnchorPoint>
                        </PointPlacement>
                      </LabelPlacement>
                      <Halo>
                        <Radius>
                          <ogc:Literal>1</ogc:Literal>
                        </Radius>
                        <Fill>
                          <CssParameter name="fill">#ffffff</CssParameter>
                        </Fill>
                      </Halo>
                      <Fill>
                        <CssParameter name="fill">#2f3133</CssParameter>
                      </Fill>
                      <VendorOption name="maxDisplacement">40</VendorOption>
                      <!--VendorOption name="displacementMode">S, SW, W, NW, N</VendorOption-->
                      <VendorOption name="conflictResolution">true</VendorOption>
                      <VendorOption name="partials">true</VendorOption>
                    </TextSymbolizer>
                  </Rule>
                </FeatureTypeStyle>
              </UserStyle>
            </NamedLayer>
          </StyledLayerDescriptor>
          SLD
          expect(@deers.sld).to match_fuzzy(resulting_sld)
        end
        it "has an feature-name" do
          expect(@deers.feature_name).to eq(:deers)
        end
      end
      context "the moose layer" do
        before do
          @moose = @sld_helper_migration.instance_variable_get("@layers_to_create")[:moose]
        end
        it "has set layer-name" do
          expect(@moose.layer_name).to eq(:moose)
        end
        it "has set the style-name" do
          expect(@moose.style_name).to eq(:moose)
        end
        it "has an sld" do
          resulting_sld = <<-SLD.strip_heredoc
            <?xml version="1.0" encoding="UTF-8"?>
            <StyledLayerDescriptor version="1.0.0"
              xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
              xmlns="http://www.opengis.net/sld"
              xmlns:ogc="http://www.opengis.net/ogc"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <NamedLayer>
                <Name>MOOSE</Name>
                <UserStyle>
                  <Name>MOOSE</Name>
                  <Title>MOOSE</Title>
                  <Abstract>MOOSE</Abstract>
                  <FeatureTypeStyle>
                    <Rule>
                      <Title>ELANDEN</Title>
                      <MaxScaleDenominator>15000</MaxScaleDenominator>
                      <PolygonSymbolizer>
                        <Fill>
                          <CssParameter name="fill">#aaaaaa</CssParameter>
                        </Fill>
                        <Stroke>
                          <CssParameter name="stroke">#000000</CssParameter>
                          <CssParameter name="stroke-width">1</CssParameter>
                        </Stroke>
                      </PolygonSymbolizer>
                    </Rule>
                  </FeatureTypeStyle>
                </UserStyle>
              </NamedLayer>
            </StyledLayerDescriptor>
          SLD
          expect(@moose.sld).to match_fuzzy(resulting_sld)
        end
        it "has an feature-name" do
          expect(@moose.feature_name).to eq(:moose)
        end
      end

      context "the alt-moose layer" do
        before do
          @moose = @sld_helper_migration.instance_variable_get("@layers_to_create")[:alt_moose]
        end
        it "has set layer-name" do
          expect(@moose.layer_name).to eq(:alt_moose)
        end
        it "has set the style-name" do
          expect(@moose.style_name).to eq(:alt_moose)
        end
        it "has set the feature-name" do
          expect(@moose.feature_name).to eq(:moose)
        end
        it "has an sld" do
          resulting_sld = <<-SLD.strip_heredoc
            <?xml version="1.0" encoding="UTF-8"?>
            <StyledLayerDescriptor version="1.0.0"
              xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
              xmlns="http://www.opengis.net/sld"
              xmlns:ogc="http://www.opengis.net/ogc"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <NamedLayer>
                <Name>ALT MOOSE</Name>
                <UserStyle>
                  <Name>ALT MOOSE</Name>
                  <Title>ALT MOOSE</Title>
                  <Abstract>ALT MOOSE</Abstract>
                  <FeatureTypeStyle>
                    <Rule>
                      <Title>DOORZICHTIGE ELANDEN</Title>
                      <MaxScaleDenominator>15000</MaxScaleDenominator>
                      <PolygonSymbolizer>
                        <Fill>
                          <CssParameter name="fill">#aaaaaa</CssParameter>
                          <CssParameter name="opacity">0.4</CssParameter>
                        </Fill>
                        <Stroke>
                          <CssParameter name="stroke">#000000</CssParameter>
                          <CssParameter name="stroke-width">1</CssParameter>
                        </Stroke>
                      </PolygonSymbolizer>
                    </Rule>
                  </FeatureTypeStyle>
                </UserStyle>
              </NamedLayer>
            </StyledLayerDescriptor>
          SLD
          expect(@moose.sld).to match_fuzzy(resulting_sld)
        end
      end

      context "the mice layer" do
        before do
          @mice = @sld_helper_migration.instance_variable_get("@layers_to_create")[:mice]
        end
        it "has set layer-name" do
          expect(@mice.layer_name).to eq(:mice)
        end
        it "has set the style-name" do
          expect(@mice.style_name).to eq(:mice)
        end
        it "has an feature-name" do
          expect(@mice.feature_name).to eq(:mice)
        end
        it "has an sld" do
          resulting_sld = <<-SLD.strip_heredoc
            <?xml version="1.0" encoding="UTF-8"?>
            <StyledLayerDescriptor version="1.0.0"
              xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
              xmlns="http://www.opengis.net/sld"
              xmlns:ogc="http://www.opengis.net/ogc"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <NamedLayer>
                <Name>MICE</Name>
                <UserStyle>
                  <Name>MICE</Name>
                  <Title>MICE</Title>
                  <Abstract>MICE</Abstract>
                  <FeatureTypeStyle>
                    <Rule>
                      <Title>MUIZEKES</Title>
                      <MaxScaleDenominator>21000</MaxScaleDenominator>
                      <LineSymbolizer>
                        <Stroke>
                          <CssParameter name="stroke">#80ff00</CssParameter>
                          <CssParameter name="stroke-width">8</CssParameter>
                        </Stroke>
                      </LineSymbolizer>
                    </Rule>
                  </FeatureTypeStyle>
                </UserStyle>
              </NamedLayer>
            </StyledLayerDescriptor>
          SLD
          expect(@mice.sld).to match_fuzzy(resulting_sld)
        end
      end
      
      context "the toads layer" do
        before do
          @toads = @sld_helper_migration.instance_variable_get("@layers_to_create")[:toads]
        end
        it "has set layer-name" do
          expect(@toads.layer_name).to eq(:toads)
        end
        it "has set the style-name" do
          expect(@toads.style_name).to eq(:toads)
        end
        it "has an feature-name" do
          expect(@toads.feature_name).to eq(:toads)
        end
        it "has an sld" do
          resulting_sld = <<-SLD.strip_heredoc
            <?xml version="1.0" encoding="UTF-8"?>
            <StyledLayerDescriptor version="1.0.0"
              xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
              xmlns="http://www.opengis.net/sld"
              xmlns:ogc="http://www.opengis.net/ogc"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <NamedLayer>
                <Name>Toads</Name>
                <UserStyle>
                  <Name>Toads</Name>
                  <Title>Toads</Title>
                  <Abstract>Toads</Abstract>
                  <FeatureTypeStyle>
                    <Rule>
                      <Title>Padden</Title>
                      <MaxScaleDenominator>25000</MaxScaleDenominator>
                      <PolygonSymbolizer>
                        <Stroke>
                          <CssParameter name="stroke">#00ff00</CssParameter>
                          <CssParameter name="stroke-width">4</CssParameter>
                          <CssParameter name="stroke-dasharray">
                            <ogc:Literal>10.0 10.0</ogc:Literal>
                          </CssParameter>
                        </Stroke>
                      </PolygonSymbolizer>
                    </Rule>
                  </FeatureTypeStyle>
                </UserStyle>
              </NamedLayer>
            </StyledLayerDescriptor>
          SLD
          expect(@toads.sld).to match_fuzzy(resulting_sld)
        end
      end

      context "the blackbirds layer" do
        before do
          @blackbirds = @sld_helper_migration.instance_variable_get("@layers_to_create")[:blackbirds]
        end
        it "has set layer-name" do
          expect(@blackbirds.layer_name).to eq(:blackbirds)
        end
        it "has set the style-name" do
          expect(@blackbirds.style_name).to eq(:blackbirds)
        end
        it "has an feature-name" do
          expect(@blackbirds.feature_name).to eq(:blackbirds)
        end
        it "has an sld" do
          resulting_sld = <<-SLD.strip_heredoc
            <?xml version="1.0" encoding="UTF-8"?>
            <StyledLayerDescriptor version="1.0.0"
              xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
              xmlns="http://www.opengis.net/sld"
              xmlns:ogc="http://www.opengis.net/ogc"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <NamedLayer>
                <Name>Blackbirds</Name>
                <UserStyle>
                  <Name>Blackbirds</Name>
                  <Title>Blackbirds</Title>
                  <Abstract>Blackbirds</Abstract>
                  <FeatureTypeStyle>
                    <Rule>
                      <Title>Raven</Title> 
                      <ogc:Filter>
                        <ogc:And>
                          <ogc:PropertyIsEqualTo>
                            <ogc:PropertyName>label</ogc:PropertyName>
                            <ogc:Literal>BLACK</ogc:Literal>
                          </ogc:PropertyIsEqualTo>
                          <ogc:PropertyIsEqualTo>
                            <ogc:PropertyName>active</ogc:PropertyName>
                            <ogc:Literal>TRUE</ogc:Literal>
                          </ogc:PropertyIsEqualTo>
                        </ogc:And>  
                      </ogc:Filter>
                      <LineSymbolizer>
                        <Stroke>
                          <CssParameter name="stroke">#00ff00</CssParameter>
                          <CssParameter name="stroke-width">3</CssParameter>
                        </Stroke>
                      </LineSymbolizer>
                    </Rule>
                  </FeatureTypeStyle>
                </UserStyle>
              </NamedLayer>
            </StyledLayerDescriptor>
          SLD
          expect(@blackbirds.sld).to match_fuzzy(resulting_sld)
        end
      end


    end
  end


  context "adding layer-groups" do
    context "initialise the migration/runner" do
      before do
        @test_connector = GeoserverMigrations::TestConnector.new
        GeoserverMigrations::Base.connection = @test_connector
        @layergroup_migration = AddALayergroup.new
      end
      it "test-prepararion has correctly set the base connector" do
        expect(GeoserverMigrations::Base.connection.class.name).to eq("GeoserverMigrations::TestConnector")
      end

      context "run it" do
        before do
          @layergroup_migration.migrate
        end
        it "has collected the layer-group's name" do
          expect(@test_connector.collected_actions[:up].map{|x| x[:params][:name]}.sort).to eq([:masterdata, :masterdata_alt])
        end

        context "the masterdata layer" do
          before do
            @masterdata = @layergroup_migration.instance_variable_get("@layers_to_create")[:masterdata]
          end
          it "has set options" do
            expect(@masterdata.options.inspect).to eq("{:layer_name=>:masterdata, :is_update_style=>false, :layers=>[\"sabic:pipelines\", \"sabic:cables\"]}")
          end
          it "has an sld" do
            expect(@masterdata.layer_name).to eq(:masterdata)
          end
        end
        context "the masterdata_alt layer" do
          before do
            @masterdata_alt = @layergroup_migration.instance_variable_get("@layers_to_create")[:masterdata_alt]
          end
          it "has set options" do
            expect(@masterdata_alt.options.inspect).to eq("{:layer_name=>:masterdata_alt, :is_update_style=>false, :layers=>[\"sabic:pipelines-alt\", \"sabic:cables-alt\"]}")
          end
          it "has an sld" do
            expect(@masterdata_alt.layer_name).to eq(:masterdata_alt)
          end
        end
        it "stores the layers to create" do
          expect(@layergroup_migration.instance_variable_get("@layers_to_create").keys.sort).to eq([:masterdata, :masterdata_alt])
        end
      end
    end
  end


end
