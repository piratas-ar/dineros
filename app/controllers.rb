Dineros::App.controllers  do
  get :index, :map => '/' do
# Obtener todo el historial
# TODO paginar
    @dineros = Dinero.all
# Mostrar el total
    @total = Dinero.sum("cantidad") / 100.0
# Obtener un listado de los que tienen plata en este momento
    @quien_los_tiene = Dinero.select("responsable, sum(cantidad) / 100 as subtotal")
                       .group("responsable").having("subtotal > 0")

# Incluir funciones para gravatar
# TODO: usar avatars.io para encontrar avatares en otros servicios?
    Haml::Helpers.send(:include, Gravatarify::Helper)

    render 'dinero/index'
  end
end
