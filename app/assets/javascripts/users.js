var alert_to_show = '';

$( document ).on('turbolinks:load', function() {
	if(alert_to_show.length > 0){
		show_success_alert(alert_to_show);
		alert_to_show = '';
	}

	init_ajax_submit('#login_form', function(){
		refresh_with_alert('Successfully signed in.');
	},
	function(data){
		$('#loginModal .modal-body').prepend('<div class="alert alert-danger" role="alert">' + data.responseJSON.error + '</div>');
	});

	init_user_modal('edit_profile_link', 'Edit profile', 'Profile saved successfully.');
	init_user_modal('sign_up_link', 'Sign up', 'Welcome to FBA Digest!');
	init_user_modal('forgot_password_link', 'Forgot password', 'We have sent you instructions for resetting your password via email.');

	$('#loginModal .btn-oauth').click(function(e){
		e.preventDefault();
		var oauth_window = popup_center($(this).attr('href'), 'Login', 500, 600);
	});
});

function init_ajax_submit(form_selector, success_callback, error_callback){
	$(form_selector).submit(function(e){
	    var form = $(this);
	    $.ajax({
	        url: form.attr('action'),
	        type: form.attr('method'),
	        data: form.serialize(),
	        dataType: 'json',
			success: success_callback,
			error: error_callback
	    });
	    return false;
	});
}

function init_user_modal(link_id, modal_label, success_message){
	$('#' + link_id).click(function() {
		$('#userModalLabel').html(modal_label);
		$('#user_modal_content').load($(this).attr('href'), function(){
			init_ajax_submit('#user_modal_content form', function(data){
				refresh_with_alert(success_message);
			},
			function(data){
				var error_text = 'Unknown error.';
				if(typeof data.responseJSON.error != 'undefined'){
					error_text = data.responseJSON.error;
				}else if(typeof data.responseJSON.errors != 'undefined'){
					var errors = data.responseJSON.errors;
					var errors_array = [];
					for(var field in errors){
						var field_name = field.charAt(0).toUpperCase() + field.replace('_', ' ').substr(1);
						var field_errors = [];
						for(var i = 0; i < errors[field].length; i++){
							field_errors.push(field_name + ' ' + errors[field][i]);
						}
						errors_array.push(field_errors.join('<br>'));
					}
					error_text = errors_array.join('<br>');
				}

				if($('#userModal .modal-body .alert-danger').length > 0){
					$('#userModal .modal-body .alert-danger').html(error_text);
				}else{
					$('#userModal .modal-body').prepend('<div class="alert alert-danger" role="alert">' + error_text + '</div>');
				}
			});
		});
	});
}

function show_success_alert(message){
	$('nav').after('<div class="container-fluid alert-block"><div class="row"><div class="col-sm-12"><p class="alert alert-success">' + message + '</p></div></div></div>');
}

function refresh_with_alert(alert){
	Turbolinks.visit('/');
	alert_to_show = alert;
}

function popup_center(url, title, w, h) {
    // Fixes dual-screen position                         Most browsers      Firefox
    var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : window.screenX;
    var dualScreenTop = window.screenTop != undefined ? window.screenTop : window.screenY;

    var width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    var height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    var left = ((width / 2) - (w / 2)) + dualScreenLeft;
    var top = ((height / 2) - (h / 2)) + dualScreenTop;
    var newWindow = window.open(url, title, 'scrollbars=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);

    // Puts focus on the newWindow
    if (window.focus) {
        newWindow.focus();
    }

    return newWindow;
}