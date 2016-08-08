xml.instruct!
xml.tag! 'soap:Envelope', 'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance' do
  xml.tag! 'soap:Body' do
    xml.tag! "soap:#{wsdl.action}Response" do
      params.each do |key, value|
        if key == :offers
          xml.offers do
            value.each do |k, v|
              if k == :marketingCopyWeb
                v[:marketingBullet].each do |mB|
                  xml.marketingCopyWeb do
                    xml.marketingBullet mB
                  end
                end
              else
                xml.tag! k, v
              end
            end
          end
        else
          xml.tag! key, value
        end
      end
    end
  end
end
