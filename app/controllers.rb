Dineros::App.controllers do
  get :index, map: '/' do
    @dineros = Dinero.all

    # Filtros
    [ :grupo, :moneda ].each do |filtro|
      next if params[filtro].blank?

      instance_variable_set('@' + filtro.to_s, params[filtro])
      @dineros = @dineros.where(Hash[filtro, params[filtro]])
    end

    [ :created_at, :responsable ].each do |filtro_empieza_por|
      next if params[filtro_empieza_por].blank?

      instance_variable_set('@' + filtro_empieza_por.to_s, params[filtro_empieza_por])
      @dineros = @dineros.where("#{filtro_empieza_por} like ?", params[filtro_empieza_por] + '%')
    end

    # Obtener todo el historial
    @dineros = @dineros
      .order(created_at: :desc)
      .page(params[:page])
      .per(params[:limit] || 10)
    # Mostrar el total
    @total = @dineros.sum(:cantidad)

    # Obtener una tabla así:
    #
    # | Moneda | Responsable | Ingreso | Egreso | Balance |
    # +--------+-------------+---------+--------+---------+
    # | ARS    | fauno       | 3000    | 300    | 2700    |
    # | BTC    | fauno       |    1    |   0    |    1    |
    sum_ingreso  = 'sum(case when cantidad > 0 then cantidad else 0 end) as ingreso'
    sum_egreso   = 'sum(case when cantidad < 0 then cantidad else 0 end) as egreso'
    sum_cantidad = 'sum(cantidad) as cantidad'

    fields = [:responsable, :moneda, sum_ingreso, sum_egreso, sum_cantidad]

    @balances = Dinero.group(:moneda).group(:responsable).select(fields)
    @balances_resumen = @dineros.group(:moneda).select(fields)
    @balance_grupal = PivotTable::Grid.new do |g|
      g.source_data = Dinero.group(:grupo)
                            .group(:moneda)
                            .select([:grupo, :moneda,
                                     'sum(cantidad) as cantidad'])

      g.column_name = :moneda
      g.row_name    = :grupo
      g.value_name  = :cantidad
    end
    @balance_grupal.build

    # Incluir funciones para gravatar
    # TODO: usar avatars.io para encontrar avatares en otros servicios?
    Haml::Helpers.send(:include, Gravatarify::Helper)

    render 'dinero/index'
  end

  get :feed, provides: :xml do
    @dineros = Dinero.all.order(created_at: :desc)
    render 'dinero/feed'
  end
end
