module GeoserverMigrations
  module SldHelpers

    def icon_style_with_label(title, icon_name, icon_style_options={})
      display_label = icon_style_options[:display_label] || title
      abstract      = icon_style_options[:abstract] || title

      filter_text = ""
      if icon_style_options[:filter].present? && icon_style_options[:filter].is_a?(Hash)
        filter_text = <<-FILTER
          <ogc:Filter>
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>#{icon_style_options[:filter].keys[0]}</ogc:PropertyName>
              <ogc:Literal>#{icon_style_options[:filter].values[0]}</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
        FILTER
      end

      max_scale_text = ""
      if icon_style_options[:max_scale_denominator].present?
        max_scale_text = "<MaxScaleDenominator>#{icon_style_options[:max_scale_denominator]}</MaxScaleDenominator>"
      end

      @options[:sld] = <<-SLD.strip_heredoc 
        <?xml version="1.0" encoding="UTF-8"?>
        <StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
          xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
          <NamedLayer>
            <Name>#{title}</Name>
            <UserStyle>
              <Name>#{title}</Name>
              <Title>#{title}</Title>
              <Abstract>#{abstract}</Abstract>
              <FeatureTypeStyle>
                <Rule>
                  <Title>#{display_label}</Title>  
                  #{filter_text}
                  #{max_scale_text}  
                  <PointSymbolizer>
                    <Graphic>
                      <ExternalGraphic>
                        <OnlineResource xlink:type="simple" xlink:href="#{icon_name}" />
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

    end

  end
end