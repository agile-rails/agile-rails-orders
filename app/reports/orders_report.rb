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

######################################################################
# A demonstration of how to make a report in with AgileRails.
#
# It makes a report of issued orders for a given period.
######################################################################
module OrdersReport

######################################################################
# Will collect data and write it to ArTemp collection.
######################################################################
def collect_data
  total = Array.new(1, 0)
  clear_data
  query_data.each do | rec|
    total[0] += rec.value
    write(order_number: rec.order_number,
          creation_date: I18n.l(rec.creation_date.to_date),
          proposer: ArUser.find(rec.proposer_id).name,
          partner: Partner.find(rec.partner_id).name,
          value: AgileHelper.format_number(rec.value))
  end
  write(partner: 'SUM OF ORDERS', value: AgileHelper.format_number(total[0]), class: 'total', end: true)
  render json: { reload: 'if_ar_temp' }
end

private

######################################################################
# Return query to select data for report
######################################################################
def query_data
  return [] if params[:record].nil?

  date_from = params[:record][:date_from].to_time.localtime.beginning_of_day
  date_to   = params[:record][:date_to].to_time.localtime.end_of_day

  qry = Order.where('creation_date >= ? and creation_date <= ?', date_from, date_to)
  qry = qry.where(sector_id: params[:record][:sector_id] ) if params[:record][:sector_id].present?
  qry.order(creation_date: 'asc')
end

################################################################################
# Will write pdf header
################################################################################
def pdf_head
  pdf_text(agile_get_site.params['company']['name'], atx: 0)
  pdf_text("Date #{I18n.l(Time.now.to_date)}", atx: 400)
  pdf_skip

  pdf_text("Orders issued from #{params[:record][:date_from]} to #{params[:record][:date_to]}", atx: 0)
  pdf_skip 2
end

end
