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

import com.google.appengine.ext.mirah.db.*


class SiteController < PublicController

  def garage
    layout nest GarageController.new
  end

  def vehicle
    layout nest VehicleController.new 
  end
  
  def fueling
    layout nest  FuelingController.new
  end
  
  def costs_notes
    layout nest  NoteController.new
  end
  
  def stats
    layout nest StatsController.new
  end
    
  def index
    layout homepage_erb
  end  


  def homepage_erb
     <<-HTML
     
     <div id="feature">
     <img class="feature-img" src="img/screenshot.png" alt="">
     <div class="feature-text">
     <h2 id="tagline">Your virtual garage</h2>
     <!-- 
     <h3 id="tagline-mini">
       We calculates your car's gas mileage and helps to manage the vehicle's costs.
     </h3>
     -->
     
     <ul class="bullet-list">
       <li>provides a profile of your car</li>
       <li>helps you to calculate and track your fuel economy and vehicle-related costs</li>
       <li>reminds you of important events such as car services</li>
     </ul>
     
     
     
     
     
     
     
    <!-- 
    <ul class="bullet-list">
      <li>Lorum</li>
      <li>Ipsum</li>
      <li>Dorum</li>
    </ul>
     <ul class="feature-screenshots">
       <li><img class="inlinepic" src="img/screenshots/buttons.jpg" height="50" width="50" alt="" /></li>
       <li><img class="inlinepic" src="img/screenshots/gallery.jpg" height="50" width="50" alt="" /></li>
       <li><img class="inlinepic" src="img/screenshots/calendars.jpg" height="50" width="50" alt="" /></li>
       <li><img class="inlinepic" src="img/screenshots/charts.jpg" height="50" width="50" alt="" /></li>
      <li> <img class="inlinepic" src="img/screenshots/coding.jpg" height="50" width="50" alt="" /></li>
      <li><img class="inlinepic" src="img/screenshots/docs.jpg" height="50" width="50" alt="" /></li>
      <li> <img class="inlinepic" src="img/screenshots/forms.jpg" height="50" width="50" alt="" /></li>
      <li> <img class="inlinepic" src="img/screenshots/gallery.jpg" height="50" width="50" alt="" /></li>
     </ul>
     <br class="cl" />
     -->
     
     <form action="/user/signup" method="post">
       <button class="blue" type="submit">Sign Up</button> It's fast and free
     </form>
     <!-- <button class="black">Tour</button> -->
     </div>
     <br class="cl" />
     </div>

     <br class="cl" />
     
    <div id="page-content" class="container_12">
           <h2 class="ribbon">How it works ?</h2>
           <div class="triangle-ribbon"></div>
     <br class="cl" />

     <ul class="services-list">
       <li> <span class="process">1</span>
         <h3>Sign up</h3> 
         <p> Sign up for free and add your vehicle.  </p>
       </li>
       <li> <span class="process">2</span>
         <h3>Add fuelings and other costs</h3> 
         <p> Keep records of all fueling and other costs  </p>
       </li>
       <li> <span class="process">3</span>
         <h3>Check your stats</h3> 
         <p> Now you can look at your own stats and compare it with users which owns the same vehicle  </p>
       </li>
     </ul>


    <br class="cl" />
        


     </div>

      HTML
  end


  def get_makers
    @vehicle_makers = VehicleMaker.all.run

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
# 	#{menu_top} 	#{userline}
  def layout(content:String)  
    
    
    if logged_in?
      login_link = <<-HTML
    <div class="fr" style="position:relative;"><div class="fr" style="width:230px;position:absolute;right:0;">
      <form action="/user/logout" method="post"><button style="float:right;display:inline;" class="small blue" type="submit">Logout</button></form>
    </div></div>
      HTML
    else
      login_link = <<-HTML
    <div class="fr" style="position:relative;"><div class="fr" style="width:230px;position:absolute;right:0;">
      <span style="float:left;display:inline;padding:8px 8px 0 0;">Allready GarageApp User ? </span>
      <form action="/user/login" method="post"><button style="float:left;display:inline;" class="small blue" type="submit">Login</button></form>
    </div></div>
      HTML
    end
    
    <<-HTML
      <!doctype html>
      <html lang="en" class="no-js">
      <head>
      <meta charset="utf-8">

      <!-- www.phpied.com/conditional-comments-block-downloads/ -->
      <!--[if IE]><![endif]-->

      <!-- Always force latest IE rendering engine (even in intranet) & Chrome Frame  -->
      <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
      <title>GarageApp</title>
      <meta name="description" content="">
      <meta name="author" content="Vojtěch Vrbka, http://vrbka.me">

      <!-- Place favicon.ico and apple-touch-icon.png in the root of your domain and delete these references -->
      <link rel="shortcut icon" href="/favicon.ico">
      <link rel="apple-touch-icon" href="/apple-touch-icon.png">

      <!-- CSS - Setup -->
      <link href="#{stylesheet_path('style.css')}" rel="stylesheet" type="text/css" />
      <link href="#{stylesheet_path('base.css')}" rel="stylesheet" type="text/css" />
      <link href="#{stylesheet_path('grid.css')}" rel="stylesheet" type="text/css" />
      <!-- CSS - Theme -->
      <link id="theme" href="#{stylesheet_path('themes/light.css')}" rel="stylesheet" type="text/css" />
      <link id="color" href="#{stylesheet_path('themes/blue.css')}" rel="stylesheet" type="text/css" />

      <link href="#{stylesheet_path('jquery-ui.css')}" rel="stylesheet" type="text/css" />
      <link href="#{stylesheet_path('ui.slider.extras.css')}" rel="stylesheet" type="text/css" />
      <link href="#{stylesheet_path('redmond/jquery-ui-1.7.1.custom.css')}" rel="stylesheet" type="text/css" />
      
      <!-- All JavaScript at the bottom, except for Modernizr which enables HTML5 elements & feature detects -->
      <script src="/js/modernizr-1.5.min.js"></script>
      
      
      
      <!-- Javascript at the bottom for fast page loading --> 
      <script src="/js/jquery-1.4.2.min.js" type="text/javascript"></script> 
      <script src="/js/jquery.tools.min.js" type="text/javascript"></script> 
      <script src="/js/jquery.lightbox-0.5.min.js" type="text/javascript"></script> 
      <script src="/js/jquery.form.js" type="text/javascript"></script> 
      <script src="/js/cufon-yui.js" type="text/javascript"></script> 
      <script src="/js/Aller.font.js" type="text/javascript"></script> 
      <script src="/js/jquery.tipsy.js" type="text/javascript"></script> 
      <script src="/js/functions.js" type="text/javascript"></script> 
      <script src="/javascripts/scripts.js" type="text/javascript"></script> 

      <script src="/javascripts/jquery-ui.js" type="text/javascript"></script> 
      <script src="/javascripts/selectToUISlider.jQuery.js" type="text/javascript"></script>         

      <!--[if lt IE 7 ]>
        <script src="/js/dd_belatedpng.js"></script>
      <![endif]-->
      
      
      </head>

      <!--[if IE 7 ]>    <body class="ie7"> <![endif]-->
      <!--[if IE 8 ]>    <body class="ie8"> <![endif]-->
      <!--[if (gt IE 9)|!(IE)]><!-->
      <body>
      <!--<![endif]-->
      <div id="wrapper"> 


      <!-- start header -->
        <header> 
          <!-- logo -->
          <h1 id="logo"><a href="/">GarageApp</a></h1>
          <!-- nav -->
          <nav>
            	#{menu_top}
              <br class="cl" />
          </nav>
          #{login_link}
          
        <br class="cl" />  

        </header>
        <!-- end header --> 

        <!-- page container -->
        <div id="page"> 
          #{content}
          <br class="cl" />
        </div>
        <!-- footer Start -->
        <footer>
          <ul class="footer-nav">
            <li><a href="index.html">Home</a> |</li>
            <li><a href="about.html">About</a> |</li>
            <li><a href="portfolio.html">Portfolio</a> |</li>
            <li><a href="services.html">Services</a> |</li>
            <li><a href="contact.html">Contact</a></li>
          </ul>
          <p>Copyright &copy; <a href="http://www.garageapp.me">GarageApp.me</a>, 2011</p>
          <br class="cl" />
        </footer>
        <!-- footer end --> 


      </div>
      </body>
      </html>

    HTML
  end
  #    <script>init_data({#{json}})</script>
end










