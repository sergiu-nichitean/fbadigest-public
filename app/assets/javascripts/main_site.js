var web_push_subscribed = false;

$(function(){
  if(window.vapidPublicKey){
    // Let's check if the browser supports notifications
    if (!("Notification" in window)) {
      console.error("This browser does not support desktop notifications");
    }

    // Let's check whether notification permissions have already been granted
    else if (Notification.permission === "granted") {
      //console.log("Permission to receive notifications has been granted");
    }

    // Otherwise, we need to ask the user for permission
    else if (Notification.permission !== 'denied') {
      Notification.requestPermission(function (permission) {
      // If the user accepts, let's create a notification
        if (permission === "granted") {
          //console.log("Permission to receive notifications has been granted");
          location.reload();
        }
      });
    }

    navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
      serviceWorkerRegistration.pushManager
      .subscribe({
        userVisibleOnly: true,
        applicationServerKey: window.vapidPublicKey
      });
    });

    if(!web_push_subscribed){
      subscribe_for_webpush();
    }
  }
});

$( document ).on('turbolinks:load', function() {
	setTimeout(function(){
		$('.alert-block').fadeOut(1000);
	}, 3000);

  //$('#sign_in_button').tooltip('show');
  //$('.navbar-toggler').click(function(){
  //  $('#sign_in_button').tooltip('hide');
  //});
  //setTimeout(function(){
  //  $('#sign_in_button').tooltip('hide');
  //}, 5000);
});

function subscribe_for_webpush(){
  navigator.serviceWorker.ready
  .then((serviceWorkerRegistration) => {
    serviceWorkerRegistration.pushManager.getSubscription()
    .then((subscription) => {
        if(subscription){
          $.post('/push-subscribe', {
            subscription: subscription.toJSON()
          }, function(){
            web_push_subscribed = true;
          });
        }
    });
  });
}