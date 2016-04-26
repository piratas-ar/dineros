require 'securerandom'
# TODO: devolver cantidad como instancias de Money
# El Dinero es una cantidad de algo en posesión de una responsable
class Dinero < ActiveRecord::Base
  timestamps
  validates_format_of :responsable,
                      with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/,
                      on: :create

  property :cantidad, as: :integer
  property :moneda, as: :string, default: 'ARS'
  property :responsable, index: true
  property :comentario, as: :text
  property :codigo, as: :string
  property :grupo, as: :string, default: 'global'

  before_create :asignar_codigo!

  def nombre
    responsable.split('@').first
  end

  def dinero
    Money.new(cantidad, moneda)
  end

  def moneda=(tipo)
    write_attribute(:moneda, tipo.upcase)
  end

  private

  def asignar_codigo!
    self.codigo = SecureRandom.uuid unless codigo
  end
end
