import dubious.*
import ext.*
import models.*
import utils.*
import tasks.*
import java.util.*
import java.util.regex.*
import java.util.ArrayList;

import org.apache.commons.codec.binary.*

import java.lang.reflect.InvocationTargetException

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import com.google.appengine.ext.duby.db.Model;

import javax.servlet.*
import javax.servlet.http.*

class PublicController < MyController
  def initialize
     @page_content = String(nil)
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
    @userline = '
      <div id="logged_in" class="'+(logged_in? ? 'visible' : 'hidden')+'">
        <span id="logged_in_email">'+(logged_in? ? user.email : '')+'</span>
         | <a href="/user/logout" onclick="logout(); return false">Logout</a>
     </div>
      <div id="logged_out" class="'+(logged_in? ? 'hidden' : 'visible')+'">
         | <a href="/user/register" onclick="show_register(); return false" >Register</a>
         | <a href="/user/login" onclick="show_login(); return false" >Sign in</a>
      </div>
      '
    
    @menu_top = '
    <ul>
        <li class="tray-active"><a href="/">Homepage</a></li>
				<li><a href="/vehicle/garage">My garage</a></li>
				<li><a href="/stats">My Stats</a></li>
	      <li><a href="/vehicle">Listing vehicles</a></li>
    </ul>'
    
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

  def menu_top
    @menu_top
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
    messages = [
      'Pokazilo se heblo',
      'Rozbil se krumpáč',
      'Polední přestávka',
      'Pauza na svačinu',
      'Ještě chvilu'
    ]
    jokes = [
      '„Nechápu, proč se nám říká horníci,” přemýšlí havíř Czudko, „když jsme celý den dole v dole.”',
      "Horník uvízne ve výtahu a zvoní mu telefon:<br/>„Ahoj, kde teď jseš?”<br/>„Ve výtahové šachtě.”<br/>„Cože, ty zase fáráš?”",
      "Jak říkají horníci sesuvu půdy?<br/>Být zavalen prací."
    ]

    r = Random.new()
    
    message = messages.get(r.nextInt(messages.size))
    joke = jokes.get(r.nextInt(jokes.size))

    html = <<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta charset="UTF-8" />
<style>
body { 
  font-family:arial, sans;
  background:url('/images/background.png');
}
#sorry { 
  margin-top:20px;
  margin-left:auto;
  margin-right:auto;
  padding:20px 30px;
  padding-left:180px;
  width:600px;
  height:300px;
  background:white url('/images/pickaxe.jpg') 20px 20px no-repeat;
  -webkit-box-shadow:0 0 10px rgba(0,0,0, 0.25);
}
h1 {
  font-size:4em;
  margin:0; 
  line-height:100%;
}
.joke {
  margin-top:1em;
  line-height:180%;
}
.retry {
  text-align:center;
}
#retry {
  font-size:1.25em;
  padding:7px 15px;
}
</style>
</head>
<body>
  <div id="page">
    <div id="sorry">
      <h1>#{message}</h1>
      <div class="joke">
        #{joke}
      </div>
      <p class="retry">
        <button id="retry" onclick="location.href = location.href">Zkusit to znova</button>
      </p>
    </div>
  </div>
<script>
var started_at = new Date().getTime();
var retry = document.getElementById('retry');
var countdown = function() {
  var now = new Date().getTime();
  var seconds = Math.floor(60 - (now-started_at)/1000); 

  if (seconds <= 0) {
    retry.innerHTML = '.. zkouším znova ..';
    location.href = location.href;
  } else {
    retry.innerHTML = 'Zkusit to znova ('+seconds+')';
    setTimeout(countdown, 100);
  }
};
countdown();
 
</script>
</body>
</html>
HTML
    html
  end

  def_edb(sorry_erb, 'views/layouts/sorry.html.erb')  
end








