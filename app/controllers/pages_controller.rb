class PagesController < ApplicationController
	before_action :add_footer
	skip_before_action :verify_authenticity_token

	def about
		@meta_description = 'FBA Digest was founded in 2018 by Serge Nikita. The Amazon landscape is constantly shifting, and there is a high need for up to date information about everything concerning FBA selling and Amazon in general.'
    @meta_title = 'About - FBA Digest'
	end

	def contact_us
		@meta_description = 'Send us a message using the online form and we\'ll get back to you as soon as possible.'
    @meta_title = 'Contact Us - FBA Digest'
	end

	def contact_us_submit
		ContactMailer.with(contact: params[:contact]).contact_email.deliver_now
		flash[:notice] = 'Thank you for contacting us, you will receive an answer shortly.'
		redirect_to '/'
	end

	def terms_of_service
		@meta_description = 'By accessing or using the Service you agree to be bound by these Terms. If you disagree with any part of the terms then you may not access the Service.'
    @meta_title = 'Terms of Service - FBA Digest'
	end

	def privacy_policy
		@meta_description = 'This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.'
    @meta_title = 'Privacy Policy - FBA Digest'
	end

	def partners
		@meta_description = 'These companies and organizations have signed partnerships with FBA Digest.'
    @meta_title = 'Partners - FBA Digest'
	end

	def resources
		@meta_description = 'Helpful resources for any Amazon seller: blogs, tools, freight forwarders, quality control and other services.'
    @meta_title = 'Resources - FBA Digest'
	end

	def budget_calculator
		@meta_description = 'Get a quick estimate of the budget need for starting your Amazon FBA Private Label business.'
    @meta_title = 'Budget Calculator - FBA Digest'
	end

	private

	def add_footer
		@has_footer = true
	end

end
