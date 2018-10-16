class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  ROLES= ['HOUSE HUNTER', 'medium', 'cold']
end
