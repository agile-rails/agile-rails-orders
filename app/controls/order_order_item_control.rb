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
# Control file for entering order items
######################################################################
module OrderOrderItemControl

######################################################################
# default filter select only records belonging to order
######################################################################
def default_filter
  OrderItem.where(order_id: params[:ids])
end

######################################################################
# No more items can be added, if order document has order number present.
######################################################################
def before_new
  can_edit?
end

######################################################################
def before_edit
  can_edit?
end

######################################################################
def before_delete
  can_edit?
end

######################################################################
# set item.order_id to order.id
######################################################################
def new_record
  @record.order_id = params[:ids]
end

######################################################################
# remember value of old item and calculate new order item value
######################################################################
def before_save
  @old_value    = @record.value
  @record.value = (@record.amount.to_d * @record.price.to_d).round(2)
end

######################################################################
# recalculate total value of order and save
######################################################################
def after_save
  recalculate_total_order_value(@old_value, @record.value)
end

######################################################################
# recalculate total value of order and save
######################################################################
def after_delete
  recalculate_total_order_value(@record.value, 0)
end

######################################################################
# set total record
######################################################################
def update_footer
  @order = Order.find(params[:ids])
  @footer_record = ['TOTAL', '', '', '', @order.value]
end

private
##################################################################
# recalculate and save total value of order
##################################################################
def recalculate_total_order_value(old_value, new_value)
  old_value ||= 0 # not set when new record
  @order = Order.find(params[:ids])
  @order.value ||= 0
  @order.value += new_value - old_value
  @order.save(touch: false)
  Agile.model_check(@order, true)

  formatted_value = AgileHelper.format_number(@order.value, 2)
  # update value on the parent dialog
  agile_update_form_element(field: :value, value: formatted_value, readonly: true)
end

##################################################################
#
##################################################################
def can_edit?
  return if Order.find(params[:ids]).order_number.blank?

  flash[:error] = 'Order document has already been created!'
  false
end

end 
