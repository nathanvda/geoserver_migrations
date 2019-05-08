module GeoserverMigrations
  class LayergroupConfig

    attr_accessor :options

    def initialize(layer_name, is_update_style=false)
      @options = {
          layer_name: layer_name,
          is_update_style: is_update_style,
          layers: []
      }
    end

    def valid?
      # at least one layer to be grouped should be present?
      options[:layers].size > 0
    end

    def layers(*received_layers)
      if received_layers.nil?
        @options[:layers]
      else
        if received_layers.is_a? String
          @options[:layers] = received_layers.split(/[,; ]/).select{|x| !x.empty?}
        elsif received_layers.is_a? Array
          received_layers.each do |received_layer|
            @options[:layers] += received_layer.split(/[,; ]/).select{|x| !x.empty?}
          end   
        end           
      end
    end

    def method_missing(method,*args,&block)
      # puts "LayerConfig method-missing: #{method.inspect}, #{args.inspect}"
      if [:layer_name].include? method.to_sym
        if args.size > 0
          value = args.size == 1 ? args.first : args
          value = value.strip if value.is_a? String
          @options[method.to_sym] = value
        else
          @options[method.to_sym]
        end
      else
        super
      end
    end
  end
end