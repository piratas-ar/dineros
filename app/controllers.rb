Dineros::App.controllers  do
  get :index, :map => '/' do
# Obtener todo el historial
    @dineros = Dinero.all.page(params[:page]).per(params[:limit] || 10)
# Mostrar el total
    @monedas = Dinero.group(:moneda).pluck(:moneda)
    @total = Dinero.sum(:cantidad)
    @totales = []
    @monedas.each do |moneda|
      total = Dinero.where(moneda: moneda).sum(:cantidad)
      @totales << Money.new(total, moneda) unless total == 0
    end
# Obtener un listado de los que tienen plata en este momento
    @quien_los_tiene = Dinero.group(:responsable).group(:moneda).
      select([:responsable, :moneda, 'sum(cantidad) as subtotal'])

# Convertir los subtotales a monedas
    @quien_los_tiene.collect do |q|
      q.subtotal = Money.new(q.subtotal, q.moneda)
    end

# Incluir funciones para gravatar
# TODO: usar avatars.io para encontrar avatares en otros servicios?
    Haml::Helpers.send(:include, Gravatarify::Helper)

    render 'dinero/index'
  end
end
