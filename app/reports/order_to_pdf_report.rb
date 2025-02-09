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
class OrderToPdfReport

##############################################################################
# Set an order number if not already defined in the order.
##############################################################################
def set_order_number(order)
  order.creation_date ||= Time.now.localtime.to_date
  number = ArKeyValueStore.get_next_value('order_number', order.creation_date.year)
  order.order_number = "#{order.creation_date.year}/#{number.to_s.rjust(4, '0')}-ORD"
  order.save

  Agile.model_check(order, true)
end

##############################################################################
# Print order items.
##############################################################################
def items(order)
  opts = { align: :left, inline_format: true, size: 10 }
  @pdf.draw_text('No.',     at: [10, @last_ypos], size: 10)
  @pdf.draw_text('amount',  at: [60, @last_ypos], size: 10)
  @pdf.draw_text('UOM',     at: [100, @last_ypos], size: 10)
  @pdf.draw_text('Item, goods, service ...', at: [135, @last_ypos], size: 10)

  @last_ypos -= 5
  top = @last_ypos + 1
  @pdf.stroke_line [5, @last_ypos], [485, @last_ypos]
  @last_ypos -= 3

  n = 1
  OrderItem.where(order_id: order.id).each do |item|
    @pdf.bounding_box([1, @last_ypos],   width: 25, height: 20) { @pdf.text("#{n}.", opts.merge!(align: :right)) }
    @pdf.bounding_box([27, @last_ypos],  width: 60, height: 20) { @pdf.text(AgileHelper.format_number(item.amount), opts) }
    @pdf.bounding_box([100, @last_ypos], width: 30, height: 20) { @pdf.text(item.uom, opts.merge!(align: :left)) }
    @pdf.bounding_box([135, @last_ypos], width: 350, height: 80) do
      @pdf.text("#{item.name}.", opts)
      @last_ypos = (@last_ypos - 80 + @pdf.cursor).to_int
    end
    @last_ypos -= 2
    @pdf.stroke_line [5, @last_ypos], [485, @last_ypos]
    @last_ypos -= 5
    n += 1
  end
  @pdf.stroke_rectangle [5, top], 480, top - @last_ypos - 5
end

##############################################################################
# Print top part of the order
##############################################################################
def top_part(order, issuer)
  opts = { align: :left, inline_format: true, size: 10 }
  @pdf.stroke_rectangle [0, 720], 230, 92
  @pdf.bounding_box([5, 715], width: 220, height: 100) do
    @pdf.text('ISSUER:', opts)
    @pdf.text(issuer['name'], opts)
    @pdf.text("#{issuer['city']}, #{issuer['address']}, #{issuer['post']}", opts)
    @pdf.text('<br>', opts)
    @pdf.text("VAT number: <b>#{issuer['vat']}</b>", opts)
  end

  # Order number
  @pdf.stroke_rectangle [250, 720], 230, 92
  @pdf.stroke_line [255, 690], [475, 690]
  @pdf.bounding_box([255, 715], width: 220, height: 100) do
    @pdf.text(' ', opts)
    @pdf.text('ORDER number:', opts)
  end

  opts[:align] = :right
  @pdf.bounding_box([325, 715], width: 150, height: 100) do
    @pdf.text(' ', opts)
    @pdf.text("<b>#{order.order_number}</b>", opts)
    @pdf.move_down 10
    @pdf.text("Date: <b>#{I18n.l(order.creation_date.to_date)}</b>", opts)
    @pdf.text("City: <b>#{issuer['city']}</b>", opts)
  end
end

##############################################################################
# Print recipient part of the order
##############################################################################
def recipient_part(order, issuer)
  recipient = order.partner
  opts = { align: :left, inline_format: true, size: 12 }
  text = <<~EOT
    RECIPIENT:
    
    <b>#{recipient.name}
    #{recipient.address}
    
    #{recipient.post}</b>
EOT
  @pdf.bounding_box([5, 610], width: 480, height: 100) do
    @pdf.text(text, opts)
  end

  # deliver to
  @pdf.stroke_line [5, 480], [480, 480]
  text = <<~EOT
    DELIVERY to address:
    <b>#{issuer['name']}, #{issuer['address']}, #{issuer['post']}
  EOT

  @pdf.bounding_box([5, 475], width: 480, height: 40) do
    @pdf.text(text, opts.merge({ size: 10 }))
    @last_ypos = (485 - @pdf.cursor - 30).to_int
  end
end

##############################################################################
# Print bottom part of the order
##############################################################################
def bottom_part(order, issuer)
  opts = { align: :left, inline_format: true, size: 10 }
  value = AgileHelper.format_number(order.value)
  text = <<~EOT
    Address your invoice to #{issuer['name']}, #{issuer['city']}, #{issuer['address']}, #{issuer['post']}.
    
    Cost center: <b>#{order.cost_center.code_and_name}</b>
    
    Estimated value: <b>#{value} #{order.currency}</b>
EOT
  @pdf.bounding_box([5, @last_ypos], width: 480, height: 150) do
    @pdf.text(text, opts)
    @last_ypos = (@last_ypos - 150 + @pdf.cursor).to_int
  end
end

##############################################################################
# Print signatures on the order.
##############################################################################
def signature(order, issuer)
  opts = { align: :left, inline_format: true, size: 10 }
  @last_ypos -= 30
  @pdf.stroke_rectangle [255, @last_ypos], 230, 92
  @last_ypos -= 5

  signer = ArUser.find(order.signer_id)
  @pdf.bounding_box([260, @last_ypos], width: 120, height: 80) do
    @pdf.text("ORDERER:<br><br><b>#{signer.name}</b>", opts)
  end

  @pdf.bounding_box([395, @last_ypos], width: 100, height: 40) do
    @pdf.text("Datum: #{I18n.l(order.creation_date.to_date)}", opts)
  end

  sign = Rails.root.join('public', signer.sign.delete_prefix('/'))
  @pdf.image(sign, at: [370, @last_ypos - 15], height: 40)

  stamp = Rails.root.join('public', issuer['stamp'])
  @pdf.image(stamp, at: [270, @last_ypos - 50], height: 100)
end

##############################################################################
# Procedure to print order document.
##############################################################################
def print_order(order_id, env)
  order = Order.find(order_id)
  set_order_number(order) if order.order_number.blank?
  issuer = env.agile_get_site.params('company')

  top_part(order, issuer)
  recipient_part(order, issuer)
  items(order)
  bottom_part(order, issuer)
  signature(order, issuer)
end

##############################################################################
# Write order document to PDF file into public/tmp directory.
#
# Return: PDF filename
##############################################################################
def perform(order_id, env)
  @pdf = Prawn::Document.new(left_margin: 50, right_margin: 60, top_margin: 10, bottom_margin: 10)
  @pdf.font_families.update(
    'Arial' => { normal: Rails.root.join('public/arial.ttf').to_s,
                 bold: Rails.root.join('public/arialbd.ttf').to_s }
  )
  @pdf.font 'Arial'

  print_order(order_id, env)

  pdf_name = "public/tmp/order-#{order_id}#{Time.now.to_i}.pdf"
  @pdf.render_file Rails.root.join(pdf_name)
  pdf_name.sub('public', '')
end

##############################################################################
# Perform report.
#
# Will return generated pdf file name relative to public folder.
##############################################################################
def self.perform(order_id, env)
  report = OrderToPdfReport.new
  report.perform(order_id, env)
end

end
