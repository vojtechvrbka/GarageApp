import dubious.*
import ext.*
import models.*
import utils.*
import tasks.*
import java.util.regex.*
import java.util.ArrayList;

import org.apache.commons.codec.binary.*

import java.lang.reflect.InvocationTargetException

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.io.PrintWriter;
import java.io.StringWriter;

import com.google.appengine.ext.duby.db.Model;


class SiteController < PublicController

  def vehicle
    c = VehicleController.new
    c.execute(params)
    @page_content = params.content
    self.page_title = c.page_title
    self.page_description = c.page_description
    main_erb
  end

  def fueling
    c = FuelingController.new
    c.execute(params)
    @page_content = params.content
    self.page_title = 'Motocash'
    self.page_description = 'motocash'
    main_erb
  end
  
    
  def index
  #  redirect_to '/vehicle/'

    self.page_title = 'Motocash'
    self.page_description = ''
    
    
    if logged_in?
      #no FB needed
      null
    else
      null
    end
    @page_content = homepage_erb
    main_erb
  end  


  def homepage_erb
     <<-HTML
        <div id="ribbon"></div> <!-- /ribbon (design/ribbon.gif) -->
            <!-- Screenshot in browser (replace tmp/browser.gif) -->
            <div id="col-browser"><a href="#"><img src="tmp/browser.gif" width="255" height="177" alt="" /></a></div> 

            <div id="col-text">

                <h2 id="slogan"><span></span>Place for your slogan.</h2>

                <p>Lorem ipsum dolor sit amet, <strong>consectetuer adipiscing</strong> elit. Nunc feugiat. In a massa. In feugiat pharetra lacus.
                In non arcu nec libero pharetra rutrum. Curabitur hendrerit <a href="#">elementum diam</a>. Vestibulum mattistae sapien eu <a href="#">vehicula accumsan</a>,
                erat quam porttitor orci, id ornare est eros et arcu. In odio. Morbi eu nisia et dolor dictum elementum. Vivamus commodo sodales felis.
                Nulla gravida tristique metus.</p>

                <p id="btns">
                    <a href="#"><img src="design/btn-tell.gif" alt="" /></a>
                    <a href="#"><img src="design/btn-purchase.gif" alt="" /></a>
                </p>

            </div> <!-- /col-text -->
      HTML
  end


  def get_makers
    @vehicle_makers = VehicleMaker.all.type_id(Long.parseLong(params[:type_id])).run

    makers = "<select name='vehicle[maker_id]' onchange=\"get_models('vehicle_model',this.value);\">"
    makers += "<option value='0'>-- choose --</option>"
    @vehicle_makers.each do |maker|
      makers += "<option value='#{maker.id}'>#{maker.name}</option>"
    end
    makers += '</select>'
  end

 
  def get_models
    @vehicle_models = VehicleModel.all.maker_id(Long.parseLong(params[:maker_id])).run

    models = "<select name='vehicle[model_id]'>"
    models += "<option value='0'>-- choose --</option>"
    @vehicle_models.each do |model|
      models += "<option value='#{model.id}'>#{model.name}</option>"
    end
    models += '</select>'
  end

  
  # def_edb(homepage_erb, 'views/site/homepage.html.erb')
  def_edb(main_erb, 'views/layouts/site.html.erb')
end










