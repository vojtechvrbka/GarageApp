import java.lang.Exception
class EarlyResponse < Exception;

  def initialize(e:RequestEvent)
    super()
    @e = e
  end
  
  def request_event:RequestEvent
    @e
  end
end

import dubious.*

import java.util.*
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import stdlib.*

import java.io.*
import org.apache.commons.fileupload.FileItemStream
import org.apache.commons.fileupload.FileItemIterator
import org.apache.commons.fileupload.servlet.ServletFileUpload
import com.google.appengine.api.datastore.Blob

import java.io.OutputStream
import javax.servlet.http.HttpServletResponse



class RequestEventMock < RequestEvent
  def initialize
    super()
    @params = HashMap.new
  end

  def mock(k:String, v:String)
    @params.put(k, v)
  end
  
  def [](k:String)
    String.valueOf(@params.get(k))
  end
end


class RequestEvent
  
  def initialize()
  end
  
  def initialize(request:HttpServletRequest, response:HttpServletResponse)
    self.request(request)
    self.response(response)
    
    #puts "base is "+@base
    @redirected = false
    @redirected_to = ''
    
    @is_multipart = false
    @files = HashMap.new
    @content_type = 'unknown'
    @content = String(null)
    process_multipart_form_data
  end
  
  def request(request:HttpServletRequest)
    @request = request
    if @request.getPathInfo != null
      @tail = @request.getPathInfo.split('/')
      @tail_pos = 1
    else
      @tail_pos = -1
    end
    @base = ''
    @request.getRequestURI.split('/').each { |chunk|
      next if chunk.equals("")
      if @tail && @tail[1].equals(chunk)
        break
      else
        @base += '/'+chunk
      end
    }
    @last_action = -1
    @params = Params.new(request)
    self
  end

  def response(response:HttpServletResponse)
    @response = response
    self
  end

  def clone:RequestEvent
    RequestEvent.new(request, response)
  end
  
  def nest
    clone._last_action(@last_action+1)
  end
  
  def eat()
    _last_action(@last_action+1)
  end
  
  def _last_action(la:int)
    #puts(link_to :index)
    @last_action = la
    @tail_pos = la
    #puts(link_to :index)
    self
  end
  
  # redirection, linking
  
  
  def reload_page
    reload_page('')
  end
  
  def reload_page(params:String)
    redirect_to request.getRequestURI + params
  end
  
  def link_to(action:String); returns String
    query = ''
    chunks = action.split('\\?')
    if chunks.length > 1
      if (chunks[0] == nil) || chunks[0].equals('')
        action = 'index'
      else
        action = chunks[0]
      end
      query = '?'+chunks[1]
    end
    
    url = ''
    if action.startsWith('/')
      url = server_url+action
    else      
      url = base_url
      i = 0
      if @tail
        @tail.each { |chunk|
          #puts 2
          if i < @last_action
            i += 1
            null
          else
            break
          end
          next if chunk.equals("")
          url += '/'+chunk
        }
      end
      unless action.equals(:index)
        url += '/'+action
      end
      url
    end
    url + query
  end
  
  def redirect_to(action:String); returns String
    query = ''
    chunks = action.split('\\?')
    if chunks.length > 1
      if (chunks[0] == nil) || chunks[0].equals('')
        action = 'index'
      else
        action = chunks[0]
      end
      query = '?'+chunks[1]
    end
    
    @redirected = true
    if action.startsWith('http://') || action.startsWith('https://')
      puts "ABSOLUTE REDIRECT"
      @redirected_to = action
      null
    elsif action.startsWith('/')
      @redirected_to = server_url+action
      null
    else      
      @redirected_to = base_url
      i = 0
      if @tail
        @tail.each { |chunk|
          if i < @last_action
            i += 1
            null
          else
            break
          end
          next if chunk.equals("")
          @redirected_to += '/'+chunk
        }
      end
      if action.equals(:index)
        @redirected_to
      else
        @redirected_to += '/'+action
      end
      null
    end
    @redirected_to += query
    raise EarlyResponse.new(self)
    'redirected'
  end
  
  def base_url    
    "#{server_url}#{@base}"
  end
  
  def server_url
    if @request.getServerPort == 80
      "http://#{@request.getServerName}"
    else
      "http://#{@request.getServerName}:#{@request.getServerPort}"
    end
  end
  
  def redirected
    @redirected
  end
  
  def redirected_to
    returns String
    @redirected_to
  end
  

  
  
  
  
  
  def post?
    request.getMethod.equals(:POST)
  end
  
  def get?
    request.getMethod.equals(:GET)
  end
  
  def ajax?
    requested_with = request.getHeader('X-Requested-With')
    (requested_with != null) && requested_with.equals('XMLHttpRequest')
  end
  
  
  def output; returns void
    if redirected
      response.setStatus(303)
      response.setHeader('Location', redirected_to)
      #puts "REDIRECT TO #{redirected_to}"
      return
    end    
    
    if content_type.equals(:bytes)
      response.getOutputStream.write(bytes)
      #puts "RETURN BYTES"
      return
    end
    
    if content_type.equals(:json)
      if has? :callback
        response.setContentType("application/javascript; charset=UTF-8")
        self.content = self[:callback]+"("+content+")"
        #puts "RETURN JSONP"
        nil
      else
        response.setContentType("application/json; charset=UTF-8")
        #puts "RETURN JSON"
        nil
      end
      response.getWriter.write(content)
      return
    end
    
    if content != null
      unless response.getContentType
        response.setContentType("text/html; charset=UTF-8")
      end
      response.getWriter.write(content)
      #puts "RETURN STRING"
      return
    end
    #puts "NOT RETURNING ANYTHING"
    return
  end
  
  def respond_bytes(b:byte[])
    self.content_type = :bytes
    self.bytes = b
    raise EarlyResponse.new(self)
  end
  
  def respond_json(json:String); returns void
    respond_json(json,true)
  end
    
  def respond_json(json:String, raise_exception:boolean); returns void
    self.content_type = :json
    @content = json
    if raise_exception
      raise EarlyResponse.new(self)
    end
  end  
  
  def respond_string(event:String); returns void
    self.content_type = :string
    @content = event
    raise EarlyResponse.new(self)
  end
  
  def bytes=(b:byte[]); @bytes = b; end
  def bytes; @bytes; end
  
  def content=(c:String)
    if self.content_type == null
      puts "Content type was #{content_type}, outputting #{c}"
      self.content_type = :string
    end
    @content = c
  end  
  
  def content_type; @content_type; end  
  def content_type=(type:string); @content_type=type; end
  
  
  def multipart?
    @is_multipart
  end
  
  def process_multipart_form_data
    ct = request.getHeader("Content-Type")
    
    if ct && ct.startsWith("multipart/form-data")
      @mutlipart_params = HashMap.new()
      @is_multipart = true
      upload = ServletFileUpload.new()
      iterator = upload.getItemIterator(request)
      
      while iterator.hasNext
        item = iterator.next #FileItemStream 
        stream = item.openStream #InputStream
        
        attr = item.getFieldName #String
        
        int len = 0
        int offset = 0
        buffer = byte[8192]
        file = ByteArrayOutputStream.new()
        
        while (len = stream.read(buffer, 0, buffer.length)) != -1
          offset += len;
          file.write(buffer, 0, len);
        end
        
        #key = attr.split("\\[|\\]")[1];
        
        if item.isFormField
          @mutlipart_params.put(attr, file.toString)
        else
          if file.size() > 0
            @mutlipart_params.put(attr, file.toByteArray)
          end
          #scoped.put(key, file.toString());
        end
      end
    end
  end
  
  def [](param:String); returns String
    if @is_multipart
      String(@mutlipart_params.get(param))
    else      
      @request.getParameter(param)
    end
  end

  
  def long(param:String):long
    if @is_multipart
      Long.parseLong(String(@mutlipart_params.get(param)))
    else      
      Long.parseLong(@request.getParameter(param))
    end
  end
  
  def for(model:String)
    ScopedParameterMap.params(request, model)
  end
  
  def multipart_for(model:String)
    map = Map(@mutlipart_params)
    result = HashMap.new()
    i = map.keySet().iterator();
    while i.hasNext
      name = String(i.next)
      if name.startsWith(model + "[") && name.endsWith("]")        
        key = name.split("\\[|\\]")[1]
        result.put(key, map.get(name))
      end
    end
    result    
  end
  
  def params
    @params
  end
  
  def has(a:String)
    if @is_multipart
      @mutlipart_params.get(a) != null
    else      
      i = request.getParameterMap.keySet().iterator();
      while i.hasNext()
        if String(i.next()).equals(a)
          return true
        end
      end
      false
    end
  end  
  def has?(a:String); has(a); end
  
  def request
    @request
  end
  
  def response
    @response
  end


  
  
  
  
  
  
  
  def content    
    @content
  end  
    
  def id
    Long.parseLong(shift)
  end
  
  def parse_long
    Long.new(shift)
  end
  
  def action
    returns String
    @last_action = @tail_pos
    tail = shift
    if tail != null
      tail
    else
      'index'
    end
  end
  
  def action?(a:string)
    token = peek
    if token != null && token.equals(a)
      action
      true
    else
      false
    end      
  end
  
  def peek
    returns String
    if @tail_pos > -1 && @tail.length > @tail_pos
      @tail[@tail_pos]
    else
      null
    end
  end
  
  def shift
    returns String
    if @tail_pos > -1 && @tail.length > @tail_pos
      @tail_pos += 1
      @tail[@tail_pos-1]
    else
      null
    end
  end

end
