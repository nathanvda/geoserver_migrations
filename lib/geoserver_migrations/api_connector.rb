module GeoserverMigrations
  class APIConnector

    def initialize
      # initialise geoserver-client
      GeoserverClient.api_root = ::GEOSERVER_MIGRATIONS_CONFIG[:geoserver_base]
      GeoserverClient.api_user = ::GEOSERVER_MIGRATIONS_CONFIG[:api][:user]
      GeoserverClient.api_password = ::GEOSERVER_MIGRATIONS_CONFIG[:api][:password]

      GeoserverClient.workspace    = GEOSERVER_MIGRATIONS_CONFIG[:workspace]
      GeoserverClient.datastore    = GEOSERVER_MIGRATIONS_CONFIG[:datastore]
      # if Rails.present?
      #   GeoserverClient.logger = Rails.logger
      # end
      GeoserverClient.logger = :stdout 
    end

    def execute(ordered_actions, direction = :up, options={})
      ordered_actions.each do |action_to_complete|
        case action_to_complete[:action]
          when :add_resource
            file_name = action_to_complete[:params][:name]
            if direction == :up
              GeoserverClient.create_resource file_name
            else
              GeoserverClient.delete_resource file_name
            end
          when :create_layer
            layer_name = action_to_complete[:params][:name]
            layer_config = action_to_complete[:params][:layer_config]
            if direction == :up
              # explicitly create style if sld given
              if !layer_config.sld.nil?
                puts " -- Create style #{layer_config.style_name}"

                GeoserverClient.create_style layer_config.style_name, sld: layer_config.sld
              end

              puts " -- Create layer #{layer_config.layer_name} [native_name = #{layer_config.feature_name}]"
              GeoserverClient.create_featuretype layer_name, native_name: layer_config.feature_name
              GeoserverClient.set_layer_style layer_name, layer_config.style_name
            else
              puts " -- delete layer #{layer_config.layer_name}"
              GeoserverClient.delete_featuretype layer_name

              if !layer_config.sld.nil?
                puts " -- delete style #{layer_config.style_name}"

                GeoserverClient.delete_style layer_config.style_name
              end

            end
          when :delete_layer
            if direction == :up
              layer_name = action_to_complete[:params][:name]
              puts " -- Delete layer #{layer_name}"
              GeoserverClient.delete_featuretype layer_name
            else
              # do nothing??
              # we should save the layer-definition in the :up direction so we can
              # restore it if needed?
            end
          when :delete_style
            if direction == :up
              style_name = action_to_complete[:params][:name]
              puts " -- Delete style #{style_name}"
              GeoserverClient.delete_style style_name
            end
          when :update_style
            if direction == :up
              style_name = action_to_complete[:params][:name]
              layer_config = action_to_complete[:params][:layer_config]
              puts " -- Updating style #{style_name}"
              GeoserverClient.update_style style_name, sld: layer_config.sld
            end
        end
      end
    end

    def test
      layers = GeoserverClient.layers
      layers["featureTypes"]["featureType"].map{|l| l["name"]}
    end

  end
end