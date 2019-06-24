jQuery(function(){
	jQuery(".question-mark").click(function(){
		jQuery("." + jQuery(this).attr("rel")).toggle();
	});

	jQuery(".close-tooltip").click(function(){
		jQuery(this).parent().hide();
	});

	jQuery("#buton_calcul").click(function(){
		var $pret_net = parseFloat(jQuery("#pret_net").val());
		var $landed_cost = parseFloat(jQuery("#landed_cost").val());
		var $unitati_lunare = parseFloat(jQuery("#unitati_lunare").val());
		var $cost_ppc = parseFloat(jQuery("#cost_ppc").val());
		var $cost_fix_marketing = parseFloat(jQuery("#cost_fix_marketing").val());
		
		if(!validate_length_numeric()){
			return;
		}

		var moment0 = $cost_fix_marketing + ($unitati_lunare * 0.75 * $landed_cost);
		var buget = moment0;
		
		var moment1 = (($unitati_lunare * (4 * $landed_cost - $pret_net + $cost_ppc)) / 4);
		if(moment1 > 0){
			buget += moment1;
		}

		var moment2 = (($unitati_lunare * (2.2 * $landed_cost - $pret_net + $cost_ppc - 2)) / 2);
		if(moment2 > 0){
			buget += moment2;
		}

		var numAnim = new CountUp("buget_total", 0, Math.ceil(buget));
    	numAnim.start();
	});

	function validate_length_numeric(){
		var fields = ["pret_net", "landed_cost", "unitati_lunare", "cost_ppc", "cost_fix_marketing"];
		var no_error = true;
		for(var i = 0; i < 5; i++){
			var $field = jQuery("#" + fields[i]);
			if($field.val().length == 0){
				show_error($field, 'This field is mandatory');
				no_error = false;
			}else{
				hide_error($field);
			}
		}

		if(!no_error){
			return false;
		}

		for(var i = 0; i < 5; i++){
			var $field = jQuery("#" + fields[i]);
			if(isNaN($field.val())){
				show_error($field, 'Please enter a number.');
				no_error = false;
			}else{
				hide_error($field);
			}
		}

		if(!no_error){
			return false;
		}

		if(parseFloat(jQuery('#pret_net').val()) < (parseFloat(jQuery('#landed_cost').val()) + parseFloat(jQuery('#cost_ppc').val()))){
			show_error(jQuery('#pret_net'), 'I advise you not to start a private label business on Amazon with a product that has a net price lower than the estimated landed cost + PPC.');
			return false;
		}else{
			hide_error(jQuery('#pret_net'));
		}

		return true;
	}

	function show_error(field, text){
		field.parent().parent().next('.error').html(text).show();
		field.addClass('error');
	}

	function hide_error(field){
		field.parent().parent().next('.error').html('').hide();
		field.removeClass('error');
	}
});