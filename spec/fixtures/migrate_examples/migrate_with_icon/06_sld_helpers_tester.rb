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

    create_layer :alt_moose do
      feature_name :moose
      polygon_style "ALT MOOSE", display_label: "DOORZICHTIGE ELANDEN", max_scale_denominator: 15000, fill_opacity: "0.4"
    end

    create_layer :mice do
      feature_name :mice
      line_style "MICE", display_label: "MUIZEKES", max_scale_denominator: 21000, stroke_colour: "#80ff00", stroke_width: 8
    end

    create_layer :toads do
      feature_name :toads
      polygon_style "Toads", display_label: "Padden", max_scale_denominator: 25000, no_fill: true, stroke_colour: "#00ff00", stroke_width: 4, stroke_dasharray: "10.0 10.0"
    end

  end

end