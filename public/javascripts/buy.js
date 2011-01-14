window.init_data = function(data) {

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

  
  /*
  var DEVEL = location.hostname == 'localhost';
  var log;  
  if (DEVEL) {
    log = function() { //console.log.apply(console, arguments); };
  } else {
    var noop = function() {};
    try {
      var console.= {
        log : noop,
        error : noop,
        warn : noop
      };
    } catch (exception) {
    }
  }
  */

  var hide = function(el) {
    try {
      el.className = el.className.replace('visible', 'hidden');
    } catch (ex) {
      //console.warn(ex);
    }
  };
  var show = function(el) {
    try {
      el.className = el.className.replace('hidden', 'visible');
    } catch (e) {
      //console.warn(e);
    }
  };
  var show_if = function(el, yes) {
    !!yes ? show(el) : hide(el);
  };
  var hide_if = function(el, yes) {
    yes ? hide(el) : show(el);
  };
  
  var fire = function(event) {
    var listeners = fire.listeners[event.event];
    if (listeners) {
      for (var i = 0; i < listeners.length; i++) {
        listeners[i](event);
      }
    } else {
      //console.warn('No listeners for', event.event, event);
    }
  };
  
  fire.listeners = {};
  
  var on = function(event, cb) {
    if (!fire.listeners[event]) {
      fire.listeners[event] = [];
    }
    fire.listeners[event].push(cb);
  };
  
  var server_event = function(response) {
    var i;
    try {
      var events = eval(response);
      for (i = 0; i < events.length; i++) {
        fire(events[i]);
      }
    } catch(exception) {
      alert('Omlouváme se, nastala neočekávaná chyba :(. Kontaktujte nás, nebo chvíli počkejte a zkuste to znova.');  
    }
  };
  
  var event = function(options) {
    return server_event;//options...
  };
  
  
  /* --------------------- site logic --------------------- */
  
  var main = this;
  window.__main = main;
  
  on('error', function (e) {
    alert(e.data);
  });
  
  on('redirect', function (e) {
    location.href = e.data;
  });
  
  on('ok', function (e) {
    //alert(e.data);
  });
  
  on('set_customer', function(e) {
    //console.log(e);
    main.data.customer = e.data;
    $('logged_in_email').innerHTML = e.data.email;
  });
  
  main.data = data;

  
  
  
  var seconds_left = 0 /*Math.floor(main.data.offer.ends_in / 1000);*/
  var started_at = new Date().getTime();
  
  
  
  
  /* --- <Voyta> --- */


  window.show_tab = function(id) {
    var i;
  	for (i=0; i<=5; i++) {
  		if($('tab_'+i) !== null) {
  			$('tab_'+i).className = '';  			
      }
			if($('tab_content_'+i) !== null) {
				$('tab_content_'+i).style.display = 'none';
      }
		}
		$('tab_'+id).className = 'active';  			
		$('tab_content_'+id).style.display = 'block';
		return false;
	};
  
  if (location.hash && location.hash !== '') {
    for (var i=0; i<=5; i++) {
      var tab = $('tab_'+i);
  		if (tab) {
        ////console.log(tab.href, location.hash);
  			if ('#'+tab.href.split('#')[1] == location.hash) {
          show_tab(i);
        }
      }
		}
  }
  
  /* --- </Voyta> --- */
  
  
  window.show_buy = function() {
    show($('overlay'));    
    //show($('next_back_buttons'));    
    show($('buy-dialog'));
    select_buy_page(0);
    $('buy_offer_id').value = main.data.offer.id;
    
    hide_if($("hide_if_logged_in"), !!main.data.customer);
    
    if (main.data.customer) {
      $('buy-pieces').focus();
    } else {
      $('buy_name').focus();
    }
  };
  
  
  var move = function(direction) {
    var ch = $('buy-form').children;
    var len = ch.length;
    
    var next = last_selected_page+direction;
    
    if (next >= 0 && next < len) {
      select_buy_page(next);
      //$('buy_prev_b').disabled = (next == 0);
      //if (next == len-1) {
      //  hide($('next_back_buttons'));
      //}
    }
  };
  
  var last_selected_page = null;
  var select_buy_page = function(next) {
    ////console.log(last_selected_page);
    var ch = $('buy-form').children;
    var page;
    if (last_selected_page != null) {
      page = ch[last_selected_page];
      page.className = page.className.replace('visible', 'hidden');
    }
    page = ch[next];
    last_selected_page = next;
    page.className = page.className.replace('hidden', 'visible');
  };

  window.buy_prev = function() {
    move(-1);
  };
  window.buy_next = function() {
    move(1);
  };

  
  
  
  window.buy = function() {
    j.ajax({
      type: 'POST',
      url: '/buy?ajax=true',
      data : j('#buy-form').serialize(),
      success: event({fail:window.hide_them_all})
    });
  };
  
  window.buy_hide = function() {
    hide($('buy-dialog'));
    hide($('overlay'));
  };
  on('buy_ok', function() {
    //buy_next();
  });
  
  
  window.show_login = function() {
    show($('overlay'));
    show($('login-dialog'));
    $('login_email').focus();
  };
  
  window.login = function() {
    j.ajax({
      type: 'POST',
      url: '/customer/login?ajax=true',
      data : j('#login-form').serialize(),
      success: server_event
    });
  };

  on('login_ok', function(e) {
    show($('logged_in'));
    hide($('logged_out'));
    hide($('overlay'));
    hide($('login-dialog'));
    //$('logged_in_email').innerHTML = $('login_email').value;
    //main.data.customer = {}; //logged in  
  });
  
  window.logout = function() {
    j.ajax({
      type: 'POST',
      url: '/customer/logout?ajax=true',
      success: function(a, b, result) {
        hide($('logged_in'));
        show($('logged_out'));
        main.data.customer = null; //logged out
      }
    });
  };
  
 
  
  window.show_register = function() {
    show($('overlay'));
    show($('register-dialog'));
    $('register_name').focus();
  };
  
  window.register = function() {
    j.ajax({
      type: 'POST',
      url: '/customer/register?ajax=true',
      data : j('#register-form').serialize(),
      success: server_event
    });
  };
  
  on('register_ok', function() {
    $('logged_in_email').innerHTML = $('register_email').value;
    show($('logged_in'));
    hide($('logged_out'));
    hide($('overlay'));
    hide($('register-dialog'));
    main.data.customer = {}; //logged in
  });
  
  window.hide_them_all = function() {
    hide($('overlay'));
    hide($('login-dialog'));
    hide($('register-dialog'));
    hide($('buy-dialog'));
  };
  
  var hide_overlay = (function(e) {
    ////console.log(e);
    var el = e.target;
    if (el.id == 'overlay' || 
        el.className.indexOf('dialog-wrap') > -1) {
      hide_them_all();      
    }
  });  
  
  

  
    document.write(
  '<div id="login-dialog" class="dialog-wrap hidden" >'+
    '<div class="dialog" style="display:block; width: 500px; margin-left:auto; margin-right:auto;">'+
      '<div class="d-close" onclick="hide_them_all()"><span>X<span></div>'+
      '<div class="d-title" align="center">Vítejte zpátky!</div>'+
      '<div class="d-content">'+
        '<form id="login-form" action="/customer/login" method="POST">'+
          '<div class="page visible">'+
            '<table>'+
            '<tr><td><label for="login_email">váš email:</label></td>'+
              '<td><input id="login_email" name="email" type="text" class="input_text" value=""/></td></tr>'+
            '<tr><td><label for="login_pass">heslo:</label></td>'+
              '<td><input id="login_pass" name="password" type="password" class="input_password" value=""/></td>'+
            '</tr></table>'+
          '</div>'+
          '<div id="login-buttons" class="buttons">'+
            '<button onclick="login(); return false">Přihlásit &raquo;</button>'+
          '</div>'+
        '</form>'+
      '</div>'+
    '</div>'+
  '</div>'+

  '<div id="register-dialog" class="dialog-wrap hidden">'+
    '<div class="dialog" style="display:block; width: 500px; margin-left:auto; margin-right:auto;">'+
      '<div class="d-close" onclick="hide_them_all()"><span>X</span></div>'+
      '<div class="d-title" align="center">Registrovat</div>'+
      '<div class="d-content">'+
        '<form id="register-form" action="/register" method="POST">'+
          '<div class="page visible">'+
            '<table><tr>'+
              '<td><label for="name">váše jméno:</label></td>'+
              '<td><input id="register_name" name="name" class="required" type="text" class="input_text" value=""/></td>'+
            '</tr><tr>'+
              '<td><label for="email">váš email:</label></td>'+
              '<td><input id="register_email" name="email" class="email required" type="text" class="input_text" value="@"/></td>'+
            '</tr><tr>'+
              '<td><label for="f_password">heslo:</label></td>'+
              '<td><input id="f_password" name="password" type="password" class="input_password" value=""/></td>'+
            '</tr><tr>'+
              '<td><label for="f_password_again">heslo znova:</label></td>'+
              '<td><input id="f_password_again" name="password_again" class="input_password" type="password" value=""/></td>'+
            '</tr></table>'+
          '</div>'+
          '<div id="buttons" class="buttons">'+
            '<button class="register" onclick="register(); return false">Registrovat &raquo;</button>'+
          '</div>'+
        '</form>'+
      '</div>'+
    '</div>'+
  '</div>'+  
  '<div id="buy-dialog" class="dialog-wrap hidden">'+
    '<div class="dialog" style="display:block; width: 500px; margin-left:auto; margin-right:auto;">'+
      '<div class="d-close" onclick="hide_them_all()"><span>X</span></div>'+
      '<div class="d-title" align="center">koupit</div>'+
      '<div class="d-content">'+
        '<form id="buy-form" onsubmit="return false" method="POST">'+
          '<div class="page hidden">'+
            '<input type="hidden" id="buy_offer_id" name="offer_id" value="">'+
            '<table id="hide_if_logged_in" class="visible">'+
              '<tr>'+
                '<td><label for="buy_name">váše jméno: </label></td>'+
                '<td><input id="buy_name" name="name" type="text" class="input_text" value=""/></td>'+
              '</tr><tr>'+
                '<td><label for="buy_email">váš email: </label></td>'+
                '<td><input id="buy_email" name="email" type="text" class="input_text" value=""/></td>'+
              '</tr>'+
            '</table><table>'+
              '<tr>'+
                '<td><label for="pieces">Počet kusů: </label></td>'+
                '<td><input name="pieces" id="buy-pieces" type="text" class="input_text" value="1"/></td>'+
                /*
              '</tr><tr>'+
                '<td><label for="payment">Platba</label></td>'+
                '<td><input class="radio" type="radio" id="payment_card" name="payment" value="card">'+
                  '<label class="radio" for="payment_card">kartou</label><br/>'+
                  '<input class="radio" type="radio" id="payment_transfer" name="payment" value="transfer">'+
                  '<label class="radio" for="payment_transfer">převodem</label>'+
                '</td>'+                
              '</tr>'+
              */
            '</table>'+
            '<p><small>Platba se provádí převodem.</small></p>'+
            '<p><small>Váš kupon Vám pošleme obratem po přijetí platby.</small></p>'+
            '<button onclick="buy()" id="buy_done_b" >Dokončit</button>'+
          '</div>'+
          '<div class="page hidden">'+
            '<h2>Děkujeme za váš nákup!</h2>'+
            '<p>Sdílet na facebooku, velký rámeček s předvyplněným textem.</p>'+
            '<button onclick="buy_hide()" id="buy_done_b" >Zavřít</button>'+
          '</div>'+
        '</form>'+
      '</div>'+
    '</div>'+
  '</div>');    
  

  j(document).ready(function() {
  
    var hours_el = $('hour');
    var minutes_el = $('minutes');
    var seconds_el = $('seconds');
    
    var d = function(number) {
      var n = Math.floor(number);
      return (n < 10) ? ("0"+n) : (n);
    }
    
    var tick = function() {
      /*
      try {
          var delta = new Date().getTime() - started_at;
          var left = seconds_left - delta/1000;
          if (left < 0) {
            left = 0;
          }
          hours_el.innerHTML = d(left / 3600);
          minutes_el.innerHTML = d(left % 3600 / 60);
          seconds_el.innerHTML = d(left % 3600 % 60);
        } catch(e) {
          //console.warn(e);
        }
      setTimeout(tick, 100);
      */
    }
    tick();
  
    j('#overlay').click(hide_overlay);
    j('.dialog-wrap').each(function () {
      j(this).click(hide_overlay);
    })    
  
  	// validate signup form on keyup and submit
    j("#register-form").validate({
      rules: {
        name: {
          required:true
        },
        email: {
  				required: true,
  				email: true
        },
        password: {
  				required: true,
  				minlength: 6
        },
        password_again: {
  				required: true,
  				equalTo: "#f_password"
        }
      },
      messages: {
        password: {
  				required: "Prosím vyplňte heslo.",
  				minlength: "Heslo musí být nejméně 6 znaků dlouhé."
        },
        password_again: {
  				required: "Prosím vyplňte heslo.",
  				equalTo: "Heslo a jeho ověření se neshodují."
        },
  			email: "Vyplňte prosím emailovou adresu."
      }
    });   
    
    j("#f_password").blur(function() {
  		j("#f_password_again").valid();
    });
    
  
  	// validate signup form on keyup and submit
    j("#login-form").validate({
      rules: {
        login_email: {
  				required: true,
  				email: true
        }
      },
      messages: {
        login_email: "Vyplňte prosím svou emailovou adresu."
      }
    });    
    
    if (main.data.offer) {
      var script = document.createElement("script");
      script.type = "text/javascript";
      script.src = "http://maps.google.com/maps/api/js?sensor=false&callback=init_map";
      document.body.appendChild(script);
      
      window.init_map = function() {
        var ll = new google.maps.LatLng(main.data.offer.lat, main.data.offer.lng);
        var map = new google.maps.Map(document.getElementById("offer_map"), {
          zoom: 10,
          center: ll,
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          scrollwheel:false
        });
        var marker = new google.maps.Marker({
          position: ll
        });
        marker.setMap(map);  
      };
    }
      
  
  });
  
};













