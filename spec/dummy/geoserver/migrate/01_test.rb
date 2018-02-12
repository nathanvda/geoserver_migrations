class Test < GeoserverMigrations::Migration

  def run

    create_layer :test_welds do
      feature_name :welds
      style_name :test_welds
      sld <<-SLD
        <?xml version="1.0" encoding="ISO-8859-1"?>
        <StyledLayerDescriptor version="1.0.0" 
         xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd" 
         xmlns="http://www.opengis.net/sld" 
         xmlns:ogc="http://www.opengis.net/ogc" 
         xmlns:xlink="http://www.w3.org/1999/xlink" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <!-- a Named Layer is the basic building block of an SLD document -->
          <NamedLayer>
            <Name>default_point</Name>
            <UserStyle>
            <!-- Styles can have names, titles and abstracts -->
              <Title>Default Point</Title>
              <Abstract>A sample style that draws a point</Abstract>
              <!-- FeatureTypeStyles describe how to render different features -->
              <!-- A FeatureTypeStyle for rendering points -->
              <FeatureTypeStyle>
                <Rule>
                  <Name>rule1</Name>
                  <Title>Green circle</Title>
                  <Abstract>A 6 pixel circle with a red fill and no stroke</Abstract>
                  <MinScaleDenominator>1000</MinScaleDenominator>
                  <MaxScaleDenominator>2500</MaxScaleDenominator>
                  <PointSymbolizer>
                    <Graphic>
                      <Mark>
                        <WellKnownName>circle</WellKnownName>
                        <Fill>
                          <CssParameter name="fill">#00FF00</CssParameter>
                        </Fill>
                      </Mark>
                      <Size>6</Size>
                    </Graphic>
                  </PointSymbolizer>
                </Rule>
                <Rule>
                  <Name>rule2</Name>
                  <Title>Green circle with label</Title>
                  <Abstract>A 6 pixel circle with a red fill and no stroke, and a label</Abstract>
                  <MaxScaleDenominator>1000</MaxScaleDenominator>
                  <PointSymbolizer>
                    <Graphic>
                      <Mark>
                        <WellKnownName>circle</WellKnownName>
                        <Fill>
                          <CssParameter name="fill">#00FF00</CssParameter>
                        </Fill>
                      </Mark>
                      <Size>6</Size>
                    </Graphic>
                  </PointSymbolizer>
                  <TextSymbolizer>
                    <Label>
                      <ogc:PropertyName>name</ogc:PropertyName>
                    </Label>
                    <Font>
                      <CssParameter name="font-family">Arial</CssParameter>
                      <CssParameter name="font-size">12</CssParameter>
                      <CssParameter name="font-style">normal</CssParameter>
                      <CssParameter name="font-weight">bold</CssParameter>
                    </Font>
                    <LabelPlacement>
                      <PointPlacement>
                        <AnchorPoint>
                          <AnchorPointX>0.1</AnchorPointX>
                          <AnchorPointY>0.0</AnchorPointY>
                        </AnchorPoint>
                        <Displacement>
                          <DisplacementX>0</DisplacementX>
                          <DisplacementY>5</DisplacementY>
                        </Displacement>
                        <Rotation>-45</Rotation>
                      </PointPlacement>
                    </LabelPlacement>
                    <Fill>
                      <CssParameter name="fill">#000000</CssParameter>
                    </Fill>
                    <VendorOption name="conflictResolution">false</VendorOption>   
                    <VendorOption name="partials">true</VendorOption>
                  </TextSymbolizer>
                </Rule>
              </FeatureTypeStyle>
            </UserStyle>
          </NamedLayer>
        </StyledLayerDescriptor>
      SLD
    end

  end
end