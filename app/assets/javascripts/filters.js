$( document ).on('turbolinks:load', function() {
	$('#filtersModal').on('show.bs.modal', function (event) {
		$('#filtersModal .modal-body').load('/filters/modal');
	});

	$('#filtersModal').on('click', '.f-source-checkbox', function(){
		f_update_sources();
		f_update_categories();
	});

	$('#filtersModal').on('click', '.f-category-checkbox', function(){
		$('.f-source-checkbox[data-category="' + $(this).val() + '"]').prop('checked', $(this).is(':checked'));
		f_update_sources();
	});

	$('#filtersModal').on('click', '#save_filters', function(){
		save_filters({sources: $('#f_selected_sources').val()});
		$('#filtersModal').modal('toggle');
	});
});

function f_update_sources(){
	var selected_sources = [];
	$('.f-source-checkbox:checked').each(function(){
		selected_sources.push($(this).val());
	});
	$('#f_selected_sources').val(selected_sources.join(','));
}

function f_update_categories(){
	$('.f-category-checkbox').each(function(){
		var my_sources = $(this).data('sources');
		if(/,/.test(my_sources)){
			my_sources = my_sources.split(',');
		}else{
			my_sources = [my_sources]
		}
		//console.log('my sources', my_sources);
		var one_selected = false;
		for(var i = 0; i < my_sources.length; i++){
			//console.log('#f-source-' + my_sources[i] + ' is checked: ', $('#f-source-' + my_sources[i]).is(':checked'));
			if($('#f-source-' + my_sources[i]).is(':checked')){
				one_selected = true;
				break;
			}
		}
		//console.log('all selected', one_selected);
		$(this).prop('checked', one_selected);
	});
}