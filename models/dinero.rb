# TODO devolver cantidad como instancias de Money
class Dinero < ActiveRecord::Base
  timestamps
  validates_format_of :responsable,
                      with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/,
                      on: :create

  property :cantidad, as: :integer
  property :moneda, as: :string, default: 'ARS'
  property :responsable, index: true
  property :comentario, as: :text

  def nombre
    responsable.split('@')[0]
  end

  def dinero
    Money.new(cantidad, moneda)
  end
end
