class Dinero < ActiveRecord::Base
  timestamps
  validates_format_of :responsable,
                      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/,
                      :on => :create

  property :cantidad, :as => :integer, :null => false
  property :responsable, :null => false, :index => true
  property :comentario, :as => :text
end
