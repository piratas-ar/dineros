Dineros::App.mailer :dineros do
  email :movimiento do |dinero, url|
    to dinero.responsable
    subject 'Notificación de dineros'
    locals dinero: dinero, url_para_desconfirmar: url
    provides :plain, :html
    render 'dineros/movimiento'
    gpg sign: true, password: ENV['GPG_PASSWORD']
  end
end
