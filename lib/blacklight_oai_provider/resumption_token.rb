module BlacklightOaiProvider
  class ResumptionToken < ::OAI::Provider::ResumptionToken
    # parses a token string and returns a ResumptionToken
    def self.parse(token_string)
      begin
        options = {}
        total = nil
        matches = /(.+):(\d+)$/.match(token_string)
        options[:last] = matches.captures[1].to_i

        parts = matches.captures[0].split('.')
        options[:metadata_prefix] = parts.shift
        parts.each do |part|
          case part
          when /^s/
            options[:set] = part.sub(/^s\(/, '').sub(/\)$/, '')
          when /^f/
            options[:from] = Time.parse(part.sub(/^f\(/, '').sub(/\)$/, '')).localtime
          when /^u/
            options[:until] = Time.parse(part.sub(/^u\(/, '').sub(/\)$/, '')).localtime
          when /^t/
            total = part.sub(/^t\(/, '').sub(/\)$/, '').to_i
          end
        end
        self.new(options, nil, total)
      rescue => err
        raise OAI::ResumptionTokenException.new
      end
    end

    def encode_conditions
      encoded_token = @prefix.to_s.dup
      encoded_token << ".s(#{set})" if set
      encoded_token << ".f(#{self.from.utc.xmlschema})" if self.from
      encoded_token << ".u(#{self.until.utc.xmlschema})" if self.until
      encoded_token << ".t(#{self.total})" if self.total
      encoded_token << ":#{last}"
    end

    def to_xml
      xml = Builder::XmlMarkup.new
      token = (self.total && (self.last > self.total)) ? '' : encode_conditions
      xml.resumptionToken(token, hash_of_attributes)
      xml.target!
    end
  end
end
