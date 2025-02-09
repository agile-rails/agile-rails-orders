#--
# Copyright (c) 2024+ Damjan Rems
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

#############################################################################
# Table of orders
#############################################################################
class Order < ApplicationRecord

has_many :order_items

belongs_to :proposer, class_name: 'ArUser', foreign_key: :proposer_id
belongs_to :signer, class_name: 'ArUser', foreign_key: :signer_id
belongs_to :sector
belongs_to :cost_center
belongs_to :partner

scope :my_orders, ->(proposer_id = nil) { where(proposer_id: proposer_id).order(id: :desc) }

validates :name, presence: true
validates :proposed_date, presence: true
validates :currency, presence: true
validate  :additional_validations

before_save :set_doc_number

#############################################################################
# Before save set order document number
#############################################################################
def set_doc_number
  return if doc_number.present?

  number = ArKeyValueStore.get_next_value('order_doc_number', proposed_date.year)
  self.doc_number = "#{proposed_date.year}/#{number}"
end

#############################################################################
# Additional validations needed on more complex models
#############################################################################
def additional_validations
end

end



