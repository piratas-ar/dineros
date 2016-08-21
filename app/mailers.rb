Dineros::App.mailer :dineros do
  email :movimiento do |dineros, url|
    to dineros.collect(&:responsable).uniq
    subject 'Notificación de dineros'
    locals dineros: dineros, url_para_desconfirmar: url
    provides :plain, :html
    render 'dineros/movimiento'
    gpg sign: true, password: ENV['GPG_PASSWORD']
  end
end
