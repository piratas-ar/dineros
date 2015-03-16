# TODO devolver cantidad como instancias de Money
class Dinero < ActiveRecord::Base
  timestamps
  validates_format_of :responsable,
                      with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/,
                      on: :create

  property :cantidad, as: :integer
  property :responsable, index: true
  property :comentario, as: :text
end
