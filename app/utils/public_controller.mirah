import dubious.*
import ext.*
import models.*
import utils.*
import tasks.*
import widgets.*
import java.util.*
import java.util.regex.*
import java.util.ArrayList;

import org.apache.commons.codec.binary.*

import java.lang.reflect.InvocationTargetException

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import com.google.appengine.ext.mirah.db.*

import javax.servlet.*
import javax.servlet.http.*

class PublicController < MyController
  def initialize
     @page_content = String(nil)
  end

  def menu_top
    if logged_in?
      SiteMenu.new(params,'nav').
           item('My garage', '/garage').
           item('My Stats', '/stats').
           item('Vehicles', '/vehicle').to_s
         
    else
      SiteMenu.new(params,'nav').
           item('Homepage', '/').
           item('Vehicles', '/vehicle').to_s
    end     
  end

  def breadcrumbs
    <<-HTML
    <ul class="breadcrumbs">
      <li>Template ></li>
      <li>About Us</li>
    </ul>
    HTML
  end

  def before_action
    
    if Application.development?      
      if cookies = params.request.getCookies
        cookies.each { |cookie|
       #   puts cookie.getName + " "
          if cookie.getName.equals(:user_id)
            unless cookie.getValue.equals('') || cookie.getValue == null
              id = Integer.parseInt(cookie.getValue)
              if user = User.get(id)
                self.user = user
              end
            end
          end
        }
      end
    end   
    
    user = self.user
    
    if logged_in?
      @userline = '
      <div id="logged_in" class="'+(logged_in? ? 'visible' : 'hidden')+'">
        <span id="logged_in_email">'+(logged_in? ? user.email : '')+'</span>
         | <a href="/user/logout">Logout</a>
     </div>'
    else
      @userline = 
       '<div id="logged_out" class="'+(logged_in? ? 'hidden' : 'visible')+'">
           <a href="/user/register">Sign up</a>
           | <a href="/user/login">Login</a>
        </div>'
    end
    self.json = "user:"+user_json
  end   
  
  def json; returns String
    @json
  end
  
  def json=(j:String)
    @json = j
  end
  
  def user_json
    if logged_in?
      "{email:'#{user.email}', id:#{user.id}}"
    else
      "null"
    end
  end
  
  def page_title=(t:String); @page_title = t; end  
  def page_title; @page_title; end

  def page_description=(t:String); @page_description = t; end  
  def page_description; @page_description; end

  def userline
    @userline
  end

  def logged_in?
    session.getAttribute(:user_id) != null 
  end
  
  def user
    if user_id = session.getAttribute(:user_id)
      User.get(Long(user_id).intValue)
    else
      User(null)
    end
  end
  
  def user=(user:User)
    if Application.development?
      if user == nil
        cookie = Cookie.new(:user_id, '')
      else
        cookie = Cookie.new(:user_id, String.valueOf(user.id))
      end    
      cookie.setPath('/')
      params.response.addCookie(cookie)
    end
    request.
      getSession().
      setAttribute(
        "user_id", 
        Long.valueOf(user.id)
      )
  end
  
  
  
  def show_500
    html = <<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta charset="UTF-8" />
</head>
<body>Error 500</body>
</html>
HTML
    html
  end

  def_edb(sorry_erb, 'views/layouts/sorry.html.erb')  
end








