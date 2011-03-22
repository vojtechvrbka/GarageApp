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
    @page_content = login_erb
    main_erb
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
  
  def register
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
    @page_content = register_erb;
    main_erb
  end  
  
  def login_erb
    <<-HTML 
    <form id="login-form" action="/user/login" method="post">
     <h2>Login</h2>
     #{@error}
      <dl>
        <dt><label for="login_email">Email:</label></dt>
        <dd><input id="login_email" name="email" type="text" class="input_text" value="#{h(params[:email])}"/></dd>
      </dl>
      <dl>
        <dt><label for="login_pass">Password:</label></dt>
        <dt><input id="login_pass" name="password" type="password" class="input_password" value=""/></dt>
      </dl>
      <dl>
        <dt>&nbsp;</dt>
        <dd><input type="submit" name="submit" value="Login"></dd>
      </dl>
    </form>
    <br style="clear:both;" />
    <a href="/user/register">Don't have a GarageApp account? Click here to sign up!</a> 
    HTML
  end
  
  def register_erb
   <<-HTML
   <form action="" method="post">
     <h2>Signup</h2>
     #{@error}
     <dl>
       <dt><label for="email">Email</label></dt>
       <dd><input type="text" name="email" id="email" value="#{h(params[:email])}"></dd>
     </dl>
     <dl>
        <dt><label for="password">Password</label></dt>
        <dd><input type="text" name="password" id="password" value=""></dd>
      </dl>
      <dl>
         <dt><label for="password_confirm">Confirm</label></dt>
         <dd><input type="text" name="password_confirm" id="password_confirm" value=""></dd>
      </dl>
      <dl>
        <dt>&nbsp;</dt>
        <dd><input type="submit" name="submit" value="Sign Up"></dd>
      </dl>
   </form>
   HTML
    
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
  
  # def_edb(login_erb, 'views/site/login.html.erb')
  def_edb(main_erb, 'views/layouts/site.html.erb')  
end










