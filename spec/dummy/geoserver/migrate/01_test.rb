class Test < GeoserverMigrations::Migration

  def run

    create_layer :flappertjes do
      feature_name :flappertjes 
    end

  end
end