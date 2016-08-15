xml.instruct!
xml.definitions 'name' => settings.service,
                'targetNamespace' => settings.namespace,
                'xmlns' => 'http://schemas.xmlsoap.org/wsdl/',
                'xmlns:soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
                'xmlns:tns' => settings.namespace,
                'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema' do

  xml.types do
    xml.tag! "xs:schema", :targetNamespace => settings.namespace, :version => settings.version, :'xmlns:tns' => settings.namespace, :'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema' do
      defined = []
      wsdl.each do |operation, formats|
        formats[:in]||={}
        formats[:out]||={}
        xml.tag! "xs:element", :name => formats[:in].keys[0], :type=> "tns:#{formats[:in].keys[0]}"
        xml.tag! "xs:element", :name => formats[:out].keys[0], :type=> "tns:#{formats[:out].keys[0]}"
        formats[:in].each do |p|
          wsdl_type xml, p, defined
        end
        formats[:out].each do |p|
          wsdl_type xml, p, defined
        end
      end
    end
  end

  wsdl.each do |operation, formats|
    xml.message :name => "#{settings.name}_#{operation}" do
      formats[:in] ||= []
      formats[:in].each do |p|
        xml.part wsdl_message(p)
      end
    end
    xml.message :name => "#{settings.name}_#{operation}Response" do
      formats[:out] ||= []
      formats[:out].each do |p|
        xml.part wsdl_message(p)
      end
    end
  end

  xml.portType :name => "#{settings.name}" do
    wsdl.keys.each do |operation|
      xml.operation :name => operation, :parameterOrder => operation do
        xml.input :message => "tns:#{settings.name}_#{operation}"
        xml.output :message => "tns:#{settings.name}_#{operation}Response"
      end
    end
  end

  xml.binding :name => "#{settings.name}Binding", :type => "tns:#{settings.name}" do
    xml.tag! "soap:binding", :style => 'document', :transport => 'http://schemas.xmlsoap.org/soap/http'
    wsdl.keys.each do |operation|
      xml.operation :name => operation do
        xml.tag! "soap:operation", :soapAction => ''
        xml.input do
          xml.tag! "soap:body",
            :use => "literal"
        end
        xml.output do
          xml.tag! "soap:body",
            :use => "literal"
        end
      end
    end
  end

  xml.service :name => settings.service do
    xml.port :name => "#{settings.name}Port", :binding => "tns:#{settings.name}Binding" do
      xml.tag! "soap:address", :location => "http://#{request.host_with_port}#{settings.endpoint}"
    end
  end
end
