begin
  require 'rails'
  module RestfulError #:nodoc:
    class Engine < ::Rails::Engine #:nodoc:
    end
  end
rescue LoadError
  #do nothing
end
