Dineros::App.mailer :dineros do
  email :movimiento do |dinero|
    to dinero.responsable
    subject 'Notificación de dineros'
    locals dinero: dinero
    provides :plain, :html
    render 'dineros/movimiento'
    gpg sign: true, password: ENV['GPG_PASSWORD']
  end
end
