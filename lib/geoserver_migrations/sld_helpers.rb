module GeoserverMigrations
  module SldHelpers


    def build_sld_filter(filter_hash)
      filter_text = ""
      filters_count = filter_hash.keys.count
      if filters_count > 0
        if filters_count == 1
          filter_text = <<-FILTER
            <ogc:Filter>
              <ogc:PropertyIsEqualTo>
                <ogc:PropertyName>#{filter_hash.keys[0]}</ogc:PropertyName>
                <ogc:Literal>#{filter_hash.values[0]}</ogc:Literal>
              </ogc:PropertyIsEqualTo>
            </ogc:Filter>
          FILTER
        elsif filters_count == 2
          filter_text = <<-FILTER
            <ogc:Filter>
              <ogc:And>
                <ogc:PropertyIsEqualTo>
                  <ogc:PropertyName>#{filter_hash.keys[0]}</ogc:PropertyName>
                  <ogc:Literal>#{filter_hash.values[0]}</ogc:Literal>
                </ogc:PropertyIsEqualTo>
                <ogc:PropertyIsEqualTo>
                  <ogc:PropertyName>#{filter_hash.keys[1]}</ogc:PropertyName>
                  <ogc:Literal>#{filter_hash.values[1]}</ogc:Literal>
                </ogc:PropertyIsEqualTo>
              </ogc:And>  
            </ogc:Filter>
          FILTER
        else
          raise StandardError.new("Unsupported filter! For now we only support 1 or 2 filter-values :( :(")
        end
      end
      filter_text
    end


    def icon_style_with_label(title, icon_name, icon_style_options={})
      display_label = icon_style_options[:display_label] || title
      abstract      = icon_style_options[:abstract] || title

      filter_text = ""
      if icon_style_options[:filter].present? && icon_style_options[:filter].is_a?(Hash)
        filter_text = build_sld_filter(icon_style_options[:filter])
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


    def polygon_style(title, style_options={})
      display_label = style_options[:display_label] || title
      abstract      = style_options[:abstract] || title

      fill_colour    = style_options[:fill_colour]    || "#aaaaaa"
      fill_opacity   = style_options[:fill_opacity]   || "1"
      stroke_colour  = style_options[:stroke_colour]  || "#000000"
      stroke_width   = style_options[:stroke_width]   || "1"
      stroke_opacity = style_options[:stroke_opacity] || "1"

      filter_text = ""
      if style_options[:filter].present? && style_options[:filter].is_a?(Hash)
        filter_text = build_sld_filter(style_options[:filter])
      end

      fill_style = ""
      unless style_options[:no_fill] == true
        fill_styles = ["<Fill>"]
        fill_styles << "                      <CssParameter name=\"fill\">#{fill_colour}</CssParameter>"
        fill_styles << "                      <CssParameter name=\"opacity\">#{fill_opacity}</CssParameter>" if style_options[:fill_opacity].present?
        fill_styles << "                    </Fill>"
        fill_style = fill_styles.join("\n")
      end


      stroke_styles = []
      unless style_options[:no_stroke] == true
        stroke_styles << "<Stroke>"
        stroke_styles << "                      <CssParameter name=\"stroke\">#{stroke_colour}</CssParameter>"
        stroke_styles << "                      <CssParameter name=\"stroke-width\">#{stroke_width}</CssParameter>"
        stroke_styles << "                      <CssParameter name=\"stroke-opacity\">#{stroke_opacity}</CssParameter>"

        if style_options[:stroke_dasharray].present?
          stroke_styles << "                      <CssParameter name=\"stroke-dasharray\">"
          stroke_styles << "                           <ogc:Literal>#{style_options[:stroke_dasharray]}</ogc:Literal>"
          stroke_styles << "                      </CssParameter>"
        end
        stroke_styles << "                    </Stroke>"
      end
      stroke_style = stroke_styles.join("\n")

      max_scale_text = ""
      if style_options[:max_scale_denominator].present?
        max_scale_text = "<MaxScaleDenominator>#{style_options[:max_scale_denominator]}</MaxScaleDenominator>"
      end

      @options[:sld] = <<-SLD.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <StyledLayerDescriptor version="1.0.0" 
         xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd" 
         xmlns="http://www.opengis.net/sld" 
         xmlns:ogc="http://www.opengis.net/ogc" 
         xmlns:xlink="http://www.w3.org/1999/xlink" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
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
                  <PolygonSymbolizer>   
                    #{fill_style}
                    #{stroke_style}
                  </PolygonSymbolizer>
                </Rule>
              </FeatureTypeStyle>
            </UserStyle>
          </NamedLayer>
        </StyledLayerDescriptor>
      SLD

    end


    def line_style(title, style_options={})
      display_label = style_options[:display_label] || title
      abstract      = style_options[:abstract] || title

      stroke_colour  = style_options[:stroke_colour]  || "#000000"
      stroke_width   = style_options[:stroke_width]   || "1"
      stroke_opacity = style_options[:stroke_opacity] || "1"

      filter_text = ""
      if style_options[:filter].present? && style_options[:filter].is_a?(Hash)
        filter_text = build_sld_filter(style_options[:filter])
      end

      max_scale_text = ""
      if style_options[:max_scale_denominator].present?
        max_scale_text = "<MaxScaleDenominator>#{style_options[:max_scale_denominator]}</MaxScaleDenominator>"
      end

      @options[:sld] = <<-SLD.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <StyledLayerDescriptor version="1.0.0" 
         xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd" 
         xmlns="http://www.opengis.net/sld" 
         xmlns:ogc="http://www.opengis.net/ogc" 
         xmlns:xlink="http://www.w3.org/1999/xlink" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
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
                  <LineSymbolizer>
                    <Stroke>
                      <CssParameter name="stroke">#{stroke_colour}</CssParameter>
                      <CssParameter name="stroke-width">#{stroke_width}</CssParameter>
                      <CssParameter name="stroke-opacity">#{stroke_opacity}</CssParameter>
                   </Stroke>
                  </LineSymbolizer>
                </Rule>
              </FeatureTypeStyle>
            </UserStyle>
          </NamedLayer>
        </StyledLayerDescriptor>
      SLD

    end

    # def polygon_style_with_label(title, style_options={})
    #   display_label = icon_style_options[:display_label] || title
    #   abstract      = icon_style_options[:abstract] || title
    #
    #
    #
    #
    #   @options[:sld] = <<-SLD
    #     <?xml version="1.0" encoding="ISO-8859-1"?>
    #     <StyledLayerDescriptor version="1.0.0"
    #      xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
    #      xmlns="http://www.opengis.net/sld"
    #      xmlns:ogc="http://www.opengis.net/ogc"
    #      xmlns:xlink="http://www.w3.org/1999/xlink"
    #      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    #       <NamedLayer>
    #         <Name>#{title}</Name>
    #         <UserStyle>
    #           <Title>#{title}</Title>
    #           <Abstract>#{abstract}</Abstract>
    #           <FeatureTypeStyle>
    #             <Rule>
    #               <Title>#{display_label}</Title>
    #               <MinScaleDenominator>10000</MinScaleDenominator>
    #               <MaxScaleDenominator>200000</MaxScaleDenominator>
    #               <PolygonSymbolizer>
    #                 <Fill>
    #                   <CssParameter name="fill">#AAAAAA</CssParameter>
    #                   <CssParameter name="fill-opacity">0.3</CssParameter>
    #                 </Fill>
    #                 <Stroke>
    #                   <CssParameter name="stroke">#FFFFFF</CssParameter>
    #                   <CssParameter name="stroke-width">3</CssParameter>
    #                 </Stroke>
    #               </PolygonSymbolizer>
    #             </Rule>
    #             <Rule>
    #               <Name>rule2</Name>
    #               <Title>Beheerkaart ingezoomed</Title>
    #               <Abstract>A polygon with a gray fill and a 3 pixel while outline and a label indicating the name</Abstract>
    #               <MaxScaleDenominator>10000</MaxScaleDenominator>
    #               <PolygonSymbolizer>
    #                 <Fill>
    #                   <CssParameter name="fill">#AAAAAA</CssParameter>
    #                   <CssParameter name="fill-opacity">0.3</CssParameter>
    #                 </Fill>
    #                 <Stroke>
    #                   <CssParameter name="stroke">#FFFFFF</CssParameter>
    #                   <CssParameter name="stroke-width">3</CssParameter>
    #                 </Stroke>
    #               </PolygonSymbolizer>
    #               <TextSymbolizer>
    #                 <Geometry>
    #                   <ogc:Function name="centroid">
    #                     <ogc:PropertyName>geom</ogc:PropertyName>
    #                   </ogc:Function>
    #                 </Geometry>
    #                 <Label>
    #                   <ogc:PropertyName>name</ogc:PropertyName>
    #                 </Label>
    #                 <Font>
    #                   <CssParameter name="font-family">Arial</CssParameter>
    #                   <CssParameter name="font-size">18</CssParameter>
    #                   <CssParameter name="font-style">normal</CssParameter>
    #                   <CssParameter name="font-weight">bold</CssParameter>
    #                 </Font>
    #                 <Halo>
    #                   <Radius>2</Radius>
    #                   <Fill>
    #                     <CssParameter name="fill">#FFFFFF</CssParameter>
    #                   </Fill>
    #                 </Halo>
    #                 <Fill>
    #                   <CssParameter name="fill">#000</CssParameter>
    #                 </Fill>
    #               </TextSymbolizer>
    #             </Rule>
    #           </FeatureTypeStyle>
    #         </UserStyle>
    #       </NamedLayer>
    #     </StyledLayerDescriptor>
    #
    #   SLD
    #
    # end

  end
end
