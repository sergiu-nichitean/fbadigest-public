$( document ).on('turbolinks:load', function() {
	$('#notificationsModal').on('show.bs.modal', function (event) {
		$('#notificationsModal .modal-body').load('/notifications/modal');
	});

	$('#notificationsModal').on('click', '.n-source-checkbox', function(){
		n_update_sources();
		n_update_categories();
	});

	$('#notificationsModal').on('click', '.n-category-checkbox', function(){
		$('.n-source-checkbox[data-category="' + $(this).val() + '"]').prop('checked', $(this).is(':checked'));
		n_update_sources();
	});

	$('#notificationsModal').on('click', '#save_notifications', function(){
		save_notifications({sources: $('#n_selected_sources').val()});
		$('#notificationsModal').modal('toggle');
	});
});

function n_update_sources(){
	var selected_sources = [];
	$('.n-source-checkbox:checked').each(function(){
		selected_sources.push($(this).val());
	});
	$('#n_selected_sources').val(selected_sources.join(','));
}

function n_update_categories(){
	$('.n-category-checkbox').each(function(){
		var my_sources = $(this).data('sources');
		if(/,/.test(my_sources)){
			my_sources = my_sources.split(',');
		}else{
			my_sources = [my_sources]
		}
		//console.log('my sources', my_sources);
		var one_selected = false;
		for(var i = 0; i < my_sources.length; i++){
			//console.log('#n-source-' + my_sources[i] + ' is checked: ', $('#n-source-' + my_sources[i]).is(':checked'));
			if($('#n-source-' + my_sources[i]).is(':checked')){
				one_selected = true;
				break;
			}
		}
		//console.log('all selected', one_selected);
		$(this).prop('checked', one_selected);
	});
}

function save_notifications(sources){
	$.get('/notifications/set_notifications', sources);
}