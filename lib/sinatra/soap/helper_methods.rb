require_relative 'param'

module Sinatra
  module Soap
    module HelperMethods

      # Return the location where we can find our views
      def soap_views()
        File.join(File.dirname(__FILE__), "..", "views")
      end

      def call_action_block
        request = Soap::Request.new(env, request, params)
        response = request.execute
        builder :response, locals: {wsdl: response.wsdl, params: response.params}, :views => self.soap_views
      rescue Soap::Error => e
        builder :error, locals: {e: e}, :views => self.soap_views
      end

      def get_wsdl
        if defined?(settings.wsdl_path)
          path = File.join(settings.public_folder, settings.wsdl_path)
          if File.exist?(path)
            File.read(path)
          else
            raise "No wsdl file"
          end
        else
          wsdl_name = self.class::WSDL_NAME
          actions = {wsdl_name => Soap::Wsdl.actions[wsdl_name]}

          builder :wsdl, locals: {wsdl: actions}, :views => self.soap_views
        end
      end

      def wsdl_occurence(param, inject, extend_with = {})
        param = Param.new(param[0], param[1], true)
        extend_with = { :name => param.name, :type => param.namespaced_type }
        data = !param.multiplied ? {} : {
          "minOccurs" => 1
        }
        extend_with.merge(data)
      end

      def wsdl_message(param)
        param = Param.new(param[0], param[1], true)
        { :name => param.name, :element => param.namespaced_type }
      end

      def wsdl_type(xml, param, defined=[])
        param = Param.new(param[0], param[1])
        more = []
        if param.struct?
          if !defined.include?(param.basic_type)
            xml.tag! "xsd:complexType", :name => param.basic_type do
              xml.tag! "xsd:sequence" do
                param.map.each do |value|
                  param_value = Param.new(value[0], value[1])
                  more << value if param_value.struct?
                  xml.tag! "xsd:element", wsdl_occurence(value, true)
                end
              end
            end
            defined << param.basic_type
          elsif !param.classified?
            raise RuntimeError, "Duplicate use of `#{param.basic_type}` type name. Consider using classified types."
          end
        end
        more.each do |p|
          wsdl_type xml, p, defined
        end
      end
    end
  end
end
