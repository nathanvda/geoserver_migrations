class AddALayergroup < GeoserverMigrations::Migration

  def run

    create_layergroup :masterdata do
      layers "sabic:pipelines", "sabic:cables"
    end

    create_layergroup :masterdata_alt do
      layers "sabic:pipelines-alt, sabic:cables-alt"
    end

  end

end