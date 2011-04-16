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

import javax.servlet.*
import javax.servlet.http.*

class UserController < SiteController

  def login
    @error = "" 
    if params.has(:email)           
      begin
        self.user = User.login(params[:email], params[:password])
        redirect_to '/'
      rescue Exception => ex
        @error = ex.getMessage
      end
    end
    layout login_erb
  end

  def logout
    session = request.getSession()
    session.setAttribute("user_id", null)
    if Application.development?
      cookie = Cookie.new(:user_id, '') 
      cookie.setPath('/')
      params.response.addCookie(cookie)
    end
    redirect_to :index
  end
  
  def signup
    @error = ""
    if params.has(:email)   
        email = params['email']
        pass = params['password']
        pass_confirm = params['password_confirm']
        
        if user = User.all.email(email).first
          @error = 'That email is already in use, please choose a new one'
        else
          begin
            pass.equals(pass_confirm) ||
              (raise ClientException.new('Password and Confirm password do not match.'))
            c = User.register( email, pass)
            if c.save
             # Emailing.new(c).on_register.send
              session.setAttribute("user_id", Long.valueOf(c.id))
            end
            redirect_to '/'
          rescue Exception => ex
            @error = ex.getMessage
          end
        end 
    end  
    layout register_erb
  end  
  
  def login_erb
    <<-HTML 
    

     <h2 class="ribbon blue full">Login</h2>
     <div class="triangle-ribbon blue"></div>
     <br class="cl" />
     
     #{error(@error)}
     <form id="login-form" action="/user/login" method="post" class="user">
        <p>
          <label for="login_email">Email:</label>
          <input id="login_email" class="middle" name="email" type="text" class="input_text" value="#{h(params[:email])}"/>
        </p>
        <p>
          <label for="login_pass">Password:</label>
          <input id="login_pass" class="middle" name="password" type="password" class="input_password" value=""/>
        </p>
        <p>    
          <button class="fr" type="submit">Login</button>
        </p>
      </form>
    <br style="clear:both;" />
    <div style="text-align:center;">
      <a href="/user/signup">Don't have a GarageApp account? Click here to sign up!</a> 
    </div>
    HTML
  end
  
  def register_erb
   <<-HTML
   
     <h2 class="ribbon blue full">SignUp</h2>
     <div class="triangle-ribbon blue"></div>
     <br class="cl" />

     #{error(@error)}
     <form action="" method="post" class="user">
       <p>
         <label for="email">Email</label>
         <input type="text" class="middle" name="email" id="email" value="#{h(params[:email])}">
       </p>
       <p>
          <label for="password">Password</label>
          <input type="password" class="middle" name="password" id="password" value="">
        </p>
        <p>
           <label for="password_confirm">Confirm</label>
           <input type="password" class="middle" name="password_confirm" id="password_confirm" value="">
        </p>
        <p>
          <button class="fr" type="submit">Sign Up</button>
        </p>
      </form>
   HTML
    
  end
  
  def error()
    ""
  end
  
  def error(message:String)
    if !message.equals('')
    <<-HTML
    <div class="notification error"> <span class="strong">Error!</span> #{message} </div>
    HTML
    else
      ''
    end
  end
  
  /*
  def login
    
    if params.has(:email)      
      self.user = User.login(params[:email], params[:password])
      if params.has(:ajax)
        if user != null
           reply_raw :set_user, user_json
           reply_ok("Jste přihlášen(a).")
        #  respond_json('{"a":"a"}');
        else
          reply_error("Špatný email, nebo heslo.")
         # respond_json('{"a":"a"}');
        end
        null
      else
      #  redirect_to '/'
        null
      end    
    end
    @page_content = login_erb
    main_erb
  end
  */

end










