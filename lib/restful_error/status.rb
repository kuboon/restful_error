# frozen_string_literal: true

require "restful_error/inflector"
require "rack/utils"

module RestfulError
  Status = Data.define(:code, :reason_phrase, :symbol, :const_name)

  STATUS_CODE_TO_SYMBOL = Rack::Utils::SYMBOL_TO_STATUS_CODE.invert

  def self.build_status_from_const(const_sym)
    const_name = const_sym.to_s
    return unless /[A-Z]/.match?(const_name[0])
    symbol = RestfulError::Inflector.underscore(const_name).to_sym
    build_status_from_symbol_or_code(symbol)
  end
  def self.build_status_from_symbol_or_code(code_or_sym)
    case code_or_sym
    when Integer
      code = code_or_sym
      symbol = STATUS_CODE_TO_SYMBOL[code]
      const_name = Inflector.camelize(symbol.to_s)
      reason_phrase = Rack::Utils::HTTP_STATUS_CODES[code]
      Status.new(code:, symbol:, const_name:, reason_phrase:)
    when Symbol
      begin
        build_status_from_symbol_or_code Rack::Utils.status_code(code_or_sym)
      rescue ArgumentError
        nil
      end
    when /\A\d{3}\z/
      build_status_from_symbol_or_code(code_or_sym.to_i)
    else
      raise ArgumentError, "Invalid argument: #{code_or_sym.inspect}"
    end
  end
end
