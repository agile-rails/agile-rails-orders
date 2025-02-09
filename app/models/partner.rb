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
# Table of partners
############################################################################
class Partner < ApplicationRecord

validates :name,      presence: true
validates :name_long, presence: true
validates :address,   presence: true
validates :post,      presence: true

############################################################################
# Returns address and post concatenated
############################################################################
def address_post
  "#{address}, #{post}"
end

############################################################################
# Will return country name for id
############################################################################
def self.country_for(country_id)
  ArUser.countries[country_id]
end

############################################################################
# Will return choices for text autocomplete based on post names, that have already been entered.
############################################################################
def self.choices_for_post(search)
  select(:post).where('post like ?', "%#{sanitize_sql(search)}%")
               .distinct[..10].map{ [_1.post, _1.post] }
end

end
