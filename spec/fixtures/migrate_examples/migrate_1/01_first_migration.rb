class FirstMigration < GeoserverMigrations::Migration

  def run

    create_layer :welds do
      style_name :welds
      feature_name :welds
    end

    create_layer :settlement_gauges do
      settlement_gauges_sld = <<-SLD
        this is a test
      SLD
      sld settlement_gauges_sld
      feature_name :settlement_gauges
    end

  end

end