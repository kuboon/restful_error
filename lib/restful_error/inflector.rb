# frozen_string_literal: true

module RestfulError
  module Inflector
    module_function

    def underscore(word_)
      return word_.underscore if word_.respond_to?(:underscore)

      word = word_.dup
      word.gsub!("::", "/")
      word.gsub!(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_")
      word.tr!("-", "_")
      word.downcase!
      word
    end

    def camelize(word_)
      return word_.camelize if word_.respond_to?(:camelize)

      word = word_.dup
      word.sub!(/^[a-z\d]*/) { ::Regexp.last_match(0).capitalize }
      word.gsub!(%r{(?:_|(/))([a-z\d]*)}) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }
      word.gsub!("/", "::")
      word
    end
  end
end
