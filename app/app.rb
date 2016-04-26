# Una aplicación para llevar registros
module Dineros
  class App < Padrino::Application
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers
    register Kaminari::Helpers::SinatraHelpers

    enable :sessions

    set :delivery_method, :sendmail
    set :mailer_defaults, from: "Dineros <dineros@#{ENV['FQDN']}>"
  end
end
