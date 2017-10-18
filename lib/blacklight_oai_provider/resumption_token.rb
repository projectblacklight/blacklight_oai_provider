module BlacklightOaiProvider
  class ResumptionToken < ::OAI::Provider::ResumptionToken
    # parses a token string and returns a ResumptionToken
    def self.parse(token_string)
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
          options[:from] = Time.zone.parse(part.sub(/^f\(/, '').sub(/\)$/, '')).utc
        when /^u/
          options[:until] = Time.zone.parse(part.sub(/^u\(/, '').sub(/\)$/, '')).utc
        when /^t/
          total = part.sub(/^t\(/, '').sub(/\)$/, '').to_i
        end
      end
      new(options, nil, total)
    rescue StandardError
      raise OAI::ResumptionTokenException
    end

    def encode_conditions
      encoded_token = @prefix.to_s.dup
      encoded_token << ".s(#{set})" if set
      encoded_token << ".f(#{from.utc.xmlschema})" if from
      encoded_token << ".u(#{self.until.utc.xmlschema})" if self.until
      encoded_token << ".t(#{total})" if total
      encoded_token << ":#{last}"
    end

    def to_xml
      xml = Builder::XmlMarkup.new
      token = total && (last > total) ? '' : encode_conditions
      xml.resumptionToken(token, hash_of_attributes)
      xml.target!
    end
  end
end
