var posts_page = 1;
var loading_posts = false;
var is_posts_page = false;
var is_saved_posts_page = false;

$( document ).on('turbolinks:load', function() {
	$('.filters-alert').insertBefore('#posts').show();
	
	var href = window.location.href;

	if(href.indexOf('?search=') !== -1){
		loading_posts = true;
		load_posts(1, true);
	}

	posts_page = 2;
	$(window).off('scroll');
	if(is_posts_page && !is_saved_posts_page){
		$(window).scroll(function() {
			if ( (($(document).height() - $(window).scrollTop() - $(window).height()) < 400) && !loading_posts ) {
				init_load_posts();
			}
		});
	}

	if(href.indexOf('?sources=') !== -1){
		save_filters({sources: href.substring(href.indexOf('sources=') + 8)});
	}

	$('#posts').on('click', '.filter-source', function(e){
		e.preventDefault();
		save_filters({sources: $(this).data('source_ids')});
	});

	$('#post_modal_content').on('click', '.filter-source', function(e){
		e.preventDefault();
		save_filters({sources: $(this).data('source_ids')});
		$('#postModal').modal('toggle');

	});

	$('main').on('click', '#reset_filters', function(e){
		e.preventDefault();
		save_filters({reset: 'true'});
	});

	$('#posts').on('click', '.external-post', function(e){
		e.preventDefault();
		$('#postModalLabel').html( $('.post-title[data-post_id="' + $(this).data('post_id') + '"]').html() );
		$('#post_modal_content').load('/posts/show_external/' + $(this).data('post_id') + '/');
	});

	$('#posts').on('click', '.save-post', function(e){
		e.preventDefault();
		var $link = $(this);
		$link.tooltip('hide');
		$.get('/posts/save_for_later/' + $link.parents('.post-container').data('post_id'), function(data){
			if(is_saved_posts_page){
				window.location.reload();
			}else{
				var saved_posts_count = parseInt($('#saved_posts_count').html());
				if($link.hasClass('badge-warning')){
					saved_posts_count += 1;
					$link.removeClass('badge-warning').addClass('badge-success').prepend('<i class="fa fa-check check-or-cross"></i>');
					$link.attr('data-original-title', 'Remove from saved posts');
				}else{
					saved_posts_count -= 1;
					$link.removeClass('badge-success').addClass('badge-warning');
					$link.children('.check-or-cross').remove();
					$link.attr('data-original-title', 'Save for later!');
				}
				$('#saved_posts_count').html(saved_posts_count);
				if(data.status){
					$('#saved_posts_link').show();
				}else{
					$('#saved_posts_link').hide();
				}
				$link.tooltip();
			}
		});
	});

	$('#posts').on('click', '.save-post-visitor', function(e){
		e.preventDefault();
		$('#signInMessageModal').modal('show');
	});

	$('#posts').on('mouseover', '.save-post.badge-success', function(e){
		$(this).children('.check-or-cross').removeClass('fa-check').addClass('fa-remove');
	});

	$('#posts').on('mouseout', '.save-post.badge-success', function(e){
		$(this).children('.check-or-cross').removeClass('fa-remove').addClass('fa-check');
	});

	$('[data-toggle="tooltip"]').tooltip();
});

$(function(){
	init_loading_animation_timeout();
});

function load_posts(page, replace){
	//console.log('load posts, page', page, 'replace', replace);
	var href = window.location.href.replace('+', ' ');
	$('#posts').css('opacity', 0.7);
	var params = {page: page};
	if(href.indexOf('?search=') !== -1){
		var search_string = decodeURIComponent(href.substring(href.indexOf('search=') + 7));
		if(search_string.length > 0){
			params.search_string = decodeURIComponent(href.substring(href.indexOf('search=') + 7));
		}
	}
	$.get('/main_site/load_posts', params, function(data){
		$.get('/main_site/update_last_visit');
		if(replace){
			$('.filters-alert').remove();
			$('#posts').html(data);
		}else{
			$('#posts').append(data);
		}
		$('.filters-alert').insertBefore('#posts').show();
		$('#posts').css('opacity', 1);
		loading_posts = false;

		init_loading_animation_timeout();

		$('[data-toggle="tooltip"]').tooltip();

		posts_page++;
	});
}

function init_load_posts(on_scroll){
	if(is_posts_page){
		loading_posts = true;
		load_posts(posts_page);
	}
}

function init_loading_animation_timeout(){
	setTimeout(function(){
		$('.post-image .loading-animation:visible').each(function(){
			$(this).parent().css('background-image', "url('/images/placeholder.jpg')");
			$(this).hide();
		});
	}, 5000);
}

function save_filters(filters){
	$('#posts').css('opacity', 0.7);
	$.get('/filters/set_filters', filters, function(){
		if(window.location.href.indexOf('?sources=') !== -1 || window.location.href.indexOf('saved-posts') !== -1){
			Turbolinks.visit('/');
		}else{
			posts_page = 1;
			load_posts(1, true);
		}
	});
}

function swap_image_loader(preload_image, post_id){
	if(document.getElementById('post_image_' + post_id)){
		var url = preload_image.src;
    	document.getElementById('post_image_' + post_id).style.backgroundImage = "url('" + url + "')";
    	document.getElementById('post_image_loader_' + post_id).style.display = 'none';
	}
}