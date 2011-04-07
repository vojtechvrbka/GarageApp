jQuery(document).ready(function($) {

//(function() {
  
  /* --------------------- framework ;)  --------------------- */
  
  var $ = function(id) {return document.getElementById(id);};
  var e = function(html) {
    var s = document.createElement('span');
    s.innerHTML = html;
    return s.removeChild(s.children[0]);
  };
  var j = jQuery;
  
  
  
  window.get_models = function(elem, maker) {
    j.ajax({
      type: 'POST',
      url: '/get_models?ajax=true&maker_id='+maker,
      success: function(result) {
        $(elem).innerHTML = result
      }
    });
  };
  
  window.get_makers = function(elem, type) {
    j.ajax({
      type: 'POST',
      url: '/get_makers?ajax=true&type_id='+type,
      success: function(result) {
        $(elem).innerHTML = result
      }
    });
  };

 });