class SldHelpersTester < GeoserverMigrations::Migration

  def run

    add_resource "deer.png"

    create_layer :deers do
      feature_name :deers
      icon_style_with_label "Deers", "deer.png"
    end

    create_layer :alt_deers do
      feature_name :deers
      icon_style_with_label "ALT DEERS", "deer_with_hart.png", display_label: "Lieve hertjes", filter: {"active" => "true"}, max_scale_denominator: 15000
    end

    create_layer :moose do
      feature_name :moose
      polygon_style "MOOSE", display_label: "ELANDEN", max_scale_denominator: 15000
    end

  end

end