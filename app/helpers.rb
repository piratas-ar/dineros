# Helper methods defined here can be accessed in any controller or view in the application

Dineros::App.helpers do
  def url_para_desconfirmar(dinero)
    request.base_url + url(:dinero, :desconfirmar, id: dinero.codigo)
  end
end
