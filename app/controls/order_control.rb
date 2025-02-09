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
#+

######################################################################
# Controls file for order form
######################################################################
module OrderControl

######################################################################
# default filter select only orders belonging to current user
######################################################################
def default_filter
  order = agile_sort_options(Order) || { id: :desc }
  agile_filter_options(Order).where("proposer_id = ? or created_by = ?", session[:user_id], session[:user_id])
                             .order(order)
end

######################################################################
# Fill some defaults
######################################################################
def new_record
  @record.proposer_id   = session[:user_id]
  @record.signer_id     = Company.manager.id
  @record.sector_id     = ArUser.find(session[:user_id]).sector_id
  @record.proposed_date = Time.now.to_date
end

#############################################################################
# Check if document can be updated
#############################################################################
def before_save
  return if @record.order_number.blank?

  flash[:error] = 'Data can not be updated after order document has been created!'
  false
end

#############################################################################
# Check if document can be deleted
#############################################################################
def before_delete
  return if @record.order_number.blank?

  flash[:error] = 'Order can not be deleted after order document has been created!'
  false
end

#############################################################################
# Create order document as PDF file and open file in a new window.
#############################################################################
def order_to_pdf
  render json: { window: OrderToPdfReport.perform(params[:id], self) }
end

#############################################################################
# Action button for creating order document is active when order items exist.
#############################################################################
def self.button_to_pdf_active(env)
  !!OrderItem.find_by(order_id: env.params[:id])
end

end 
