


import java.util.HashMap
import java.util.ArrayList
import java.util.regex.Pattern
  
class Element
  def self.select:Select
    Select.new
  end
  
  def self.a:A
    A.new
  end
  
  def self.select(name:String)
    Select.new.name(name)
  end
  
protected 

  def initialize
  end
  
public 
  
  def initialize(tag_name:String)
    @tag_name = tag_name
    @attributes = HashMap(nil)
    @inner_text = String(nil)
    @children = ArrayList(nil)
  end
  
  def class(className:String)
    set(:class, className)
  end
  
  def to_s
    html = begin_tag
    if inner = self.html
      html += inner
    end
    html += end_tag
    html
  end
  
  def begin_tag
    "<#{@tag_name}#{html_attributes}>"
  end
  
  def html_attributes
    a = ''
    if @attributes != null
      i = @attributes.keySet().iterator()
      while i.hasNext
        key = i.next
        a+=" #{key}=\"#{Element.html_escape(String(@attributes.get(key)))}\""
      end
    end
    a
  end
  
  def get(attribute:String)
    String(@attributes.get(attribute))
  end
  
  def set(attribute:String, value:String)
    unless @attributes
      @attributes = HashMap.new
    end
    if value
      @attributes.put(attribute, value)
      self
    else
      remove(attribute)
    end
  end
  
  def remove(attribute:String)
    @attributes.remove(attribute)
    self
  end
  
  def html()
    if @children
      html = ''
      @children.each { |child|
        html += child.toString
      }
      html
    elsif @inner_html
      @inner_html
    end    
  end
  
  def children
    @children
  end
  
  def html(html:string)
    @inner_html = html
    self
  end
  
  def text(text:String)
    @inner_html = Element.escape_html(text)
    self
  end
  
  def append_child(e:Element)
    unless @children
      @children = ArrayList.new()
    end
    @children.add(e)
  end
  
  def add(html:String)
    @children.add(TextElement.new(html))
  end
  
  # escape special characters

  def self.initialize; returns :void
    @escape_pattern = Pattern.compile("[<>&'\"]")
    @escaped = HashMap.new
    @escaped.put("<", "&lt;")
    @escaped.put(">", "&gt;")
    @escaped.put("&", "&amp;")
    @escaped.put("\"", "&quot;")
    @escaped.put("'", "&#39;")
  end    
  
  def self.html_escape(text:String)
    return "" unless text
    matcher = @escape_pattern.matcher(text)
    buffer = StringBuffer.new
    while matcher.find
      replacement = String(@escaped.get(matcher.group))
      matcher.appendReplacement(buffer, replacement)
    end
    matcher.appendTail(buffer)
    return buffer.toString
  end    
  
  def self.escape_html(html:String); html_escape(html); end
  
  def end_tag
    if pair_tag?
      "</#{@tag_name}>"
    else
      ""
    end
  end
  
  def pair_tag?
    true
  end
  
  def toString
    to_s
  end

  
  
  
  
  
  
  
  class TextElement < Element
    def initialize(html:String)
      super()
      @html = html
    end
    
    def to_s
      @html
    end
  end

  
  class A < Element
    def initialize
      super(:a)
    end
    
    def href(url:String)
      set(:href, url)
      self
    end
    
    def href
      get(:href)
    end
    
    def html(h:String)
      super(h)
      self
    end
  end
  

  class Option < Element
    def initialize
      super(:option)
    end
    
    def value(value:string)
      self.set(:value, value)
    end
    
  end
  
  
  class Select < Element
    def initialize
      super(:select)
      @selected = Element(nil)
    end
    
    def option(value:string)
      option(value, value)
    end
    
    def option(value:string, caption:string)
      append_child Option.new.
        set(:value, value).
        html(caption)
      self
    end
    
    def name(n:String)
      set(:name, n)
      self
    end

    def option(value:int, caption:String)
      option(String.valueOf(value), caption)
    end
    
    def option(value:long, caption:String)
      option(String.valueOf(value), caption)
    end
    
    def value(value:string)
      if @selected
        @selected.remove(:selected)
      end
      children.each { |_child|
        child = Element(_child)
        if child.get(:value).equals(value)
          @selected = child.set(:selected, :selected)
        end
      }
      self
    end
    
    def value(v:int)
      value(String.valueOf(v))
    end

    def value(v:long)
      value(String.valueOf(v))
    end
  end

end
