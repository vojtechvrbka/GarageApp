import dubious.*
import ext.*
import models.*
import utils.*

import java.lang.Math

class  NoteController < PublicController
  
  
  def index
    redirect_to :index
  end
  
  
  def new
    @new = true
    @fueling = Fueling.blank
    edit_erb
  end
  
  def edit
    @new = false
    if @vehicle = Vehicle.get(Integer.parseInt(params[:vehicle]))
   #   if @vehicle.user_id == user.id
        @fueling = Fueling.get(params.id)
        null
  #    else
  #      redirect_to :index
  #      null
  #    end  
    else
      redirect_to :index
      null
    end
    edit_erb
  end  
  


  
  
  def edit_erb
    

    price_currency_select  = Element.select('note[price_currency]').
                             option("USD", "USD").
                             option("EUR", "EUR").
                             value(@fueling.price_currency).to_s
     type_select =  Element.select('note[cost_type]').
                             option(Fueling.COST_MAINTENANCE, "Maintenance").
                             option(Fueling.COST_REPAIR, "Repair").
                             option(Fueling.COST_CHANGE_TIRES, "Change tires").
                             option(Fueling.COST_CHANGE_OIL, "Change oil").
                             option(Fueling.COST_INSURANCE, "Insurance").
                             option(Fueling.COST_TAX, "Tax").
                             option(Fueling.COST_SUPERVISORY_BOARD, "Supervisory board").
                             option(Fueling.COST_TUNING, "Tuning").
                             option(Fueling.COST_ACCESSORIES, "Accessories").
                             option(Fueling.COST_PURCHASE_PRICE, "Purchase price").
                             option(Fueling.COST_MISCELLANEOUS, "Miscellaneous").
                             option(Fueling.COST_CARE, "Care").
                             option(Fueling.COST_PAYMENT, "Payment").
                             option(Fueling.COST_REGISTRATION, "Registration").
                             option(Fueling.COST_FINANCING, "Financing").
                             option(Fueling.COST_REFUND, "Refund").
                             option(Fueling.COST_FINE, "Fine").
                             option(Fueling.COST_PARKING_TAX, "Parking tax").
                             option(Fueling.COST_TOLL, "Toll").
                             option(Fueling.COST_SPARE_PARTS, "Spare parts").
                             value(@fueling.cost_type).to_s
                                      
     <<-HTML
    <h2 class="ribbon full">#{@new ? 'Add note/cost entry' : 'Edit note/cost entry'}</h2>
        <div class="triangle-ribbon"></div>
        <br class="cl" />
        
    <form method="post" action="/costs_notes/save/#{String.valueOf(@fueling.url_id)}?vehicle=#{params[:vehicle]}">
      <dl>
        <dt><label for="date">Date:</label></dt>
    		<dd>
    		  <input type="text" class="date-field" id="date_to_human">
    		  <input type="hidden" id="date_to_ts"  name="note[date]" value="#{h(Long.toString(@fueling.date))}">	
    		</dd>
      </dl>
      <dl>
        <dt><label for="odometer">Odometer:</label></dt>
    		<dd><input type="text" id="odometer" name="note[odometer]" value="#{h(Long.toString(@fueling.odometer))}"></dd>
      </dl>  
      <dl>
        <dt><label for="type">Type:</label></dt>
    		<dd>#{type_select}</dd>
      </dl>

      <dl>
        <dt><label for="price">Price:</label></dt>
    		<dd><input type="text" id="price" name="note[price]" value="#{h(Double.toString(@fueling.price))}">  
    		  #{price_currency_select}
    		  </dd>
      </dl>
      
      <dl>
        <dt><label for="note">Note:</label></dt>
    		<dd><textarea id="note" name="note[note]" style="width:300px;height:80px;">#{h(@fueling.note)}</textarea></dd>
      </dl>
     	

     	
     	<dl>
    		<dt>
    			<button type="submit">#{@new ? 'Create' : 'Update'}</button>
    		</dt>
    	</dl>
    </form>
    <script>
    	$(function() 
      {
        console.log('yes');
        $('.date-field').each(function() {
          var ts_field = $('#'+this.id.replace('human', 'ts'))[0];
          ts_field.value = ts_field.value*1 + new Date().getTimezoneOffset()*60*1000;
          var dp = $(this).datepicker({
            altField: ts_field,
      			altFormat: '@',
            dateFormat: 'mm/dd/yy',
            firstDay: 0,
            /*
            onSelect: function(dateText) { 
              //ts_field.value = ts_field.value*1 - new Date().getTimezoneOffset()*60*1000;
            } 
            */
          });

          $(this.form).submit(function() {
              ts_field.value = ts_field.value*1 - new Date().getTimezoneOffset()*60*1000;
            })

          var date = new Date();
          date.setTime(ts_field.value);
          //console.log(ts_field);
          this.value = $.datepicker.formatDate('mm/dd/yy', date);

        })
    	});
    </script>
    HTML
  end

end