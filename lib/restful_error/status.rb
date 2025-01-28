# frozen_string_literal: true

require "restful_error/inflector"
require "rack/utils"

module RestfulError
  STATUS_CODE_TO_SYMBOL = Rack::Utils::SYMBOL_TO_STATUS_CODE.invert
  def self.code_from(code_or_sym_or_const_name)
    case code_or_sym_or_const_name
    when Integer
      code_or_sym_or_const_name
    when Symbol
      str = code_or_sym_or_const_name.to_s
      sym = /[A-Z]/.match?(str[0]) ? RestfulError::Inflector.underscore(str).to_sym : code_or_sym_or_const_name
      begin
        Rack::Utils.status_code(sym)
      rescue ArgumentError
        nil
      end
    when /\A\d{3}\z/
      code_from(code_or_sym_or_const_name.to_i)
    else
      raise ArgumentError, "Invalid argument: #{code_or_sym_or_const_name.inspect}"
    end
  end

  Status = Data.define(:code, :reason_phrase, :symbol, :const_name) do
    def initialize(code:)
      reason_phrase = Rack::Utils::HTTP_STATUS_CODES[code]
      raise ArgumentError, "Invalid status code: #{code}" unless reason_phrase

      symbol = STATUS_CODE_TO_SYMBOL[code]
      const_name = Inflector.camelize(symbol.to_s)
      super(code:, reason_phrase:, symbol:, const_name:)
    end
  end
end
