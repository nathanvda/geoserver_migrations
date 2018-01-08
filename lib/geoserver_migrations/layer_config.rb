module GeoserverMigrations
  class LayerConfig

    attr_accessor :sld, :layer_name, :feature_name, :style_name

    def valid?
      # at least feature-name should be present?
      feature_name.present?
    end

  end
end