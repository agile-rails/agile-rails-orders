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

############################################################################
# Table of company's cost centers
############################################################################
class CostCenter < ApplicationRecord

belongs_to :sector
belongs_to :ar_user

validates :code,  presence: true
validates :name,  presence: true

############################################################################
# Returns code and name concatenated.
############################################################################
def code_and_name
  "#{code} #{name}"
end

############################################################################
# Return choices for selecting only cost centers defined for the sector. Select field
# id dependent on value of sector_id.
############################################################################
def self.choices_for_cost_center_in_sector(sector_id)
  return [] if sector_id.blank?

  where(sector_id: sector_id).order(:code).map{ [_1.code_and_name, _1.id] }
end

end
