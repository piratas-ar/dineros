class Dinero < ActiveRecord::Base
  timestamps

  property :cantidad, :as => :integer, :null => false
  property :responsable, :null => false
  property :comentario, :as => :text
end
