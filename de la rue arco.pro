%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE LA RUE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_la_rue, `18 June 2015` ).

% i_pdf_parameter( space, 2 ).
% i_pdf_parameter( tab, 10 ).
% i_pdf_parameter( same_line, 6 ).
%	i_pdf_parameter( font_size, 20 ).  
%	i_pdf_parameter( max_pages, 1 ).
% i_pdf_parameter( direct_object_mapping, 0 ).

i_rules_file( `arco address lookup.pro` ).

%============================================================================
%		Reprinting Script
%============================================================================
i_op_param( extract_script_file_name, _, _, _, _, `utils.ps1` ).
i_op_param( extract_script_function_name, _, _, _, _, `bullzip` ).

i_date_format(_).

i_user_field( invoice, i_site_delivery_point, `Site Delivery Point` ).
i_c_xml_extrinsic( order, single, i_site_delivery_point, `Site Delivery Point` ).

i_user_field( invoice, i_ship_to_phone_number, `Ship To Phone Number` ).
i_c_xml_extrinsic( order, single, i_ship_to_phone_number, `Ship To Phone Number` ).

i_user_field( invoice, i_order_requested_by, `Order Requested By` ).
i_c_xml_extrinsic( order, single, i_order_requested_by, `Order Requested By` ).

i_user_field( line, l_order_requested_by, `Order Requested By` ).
i_c_xml_extrinsic( order_line, single, l_order_requested_by, `Order Requested By` ).

i_user_field( line, l_site_delivery_point, `Site Delivery Point` ).
i_c_xml_extrinsic( order_line, single, l_site_delivery_point, `Site Delivery Point` ).

i_op_param( c_xml_shared_secret, _, _, _, `arcoarco01` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_details

	, get_order_number
	
	, get_order_date
	
	, get_i_order_requested_by

	, [ q0n(line), get_invoice_totals ] 
	
	, get_invoice_lines
	
	, get_alternate_invoice_lines

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%	Required to overide the Address lookup on the old variety
i_final_rule( [ peek_fails( test( alternate ) ), general_ledger_code( `105294` ) ] ).
%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  set( purchase_order )

	, buyers_code_for_buyer( `thomasderue` )
	, supplier_registration_number( `thomasderue` )
	
	, agent_code_1(`DUNS`)
	, agent_code_2(`DUNS`)
	, agent_code_3(`DUNS`)

	, agent_name(`54334`)
	% , agent_name(`12345`)

	, buyers_code_for_supplier(`212141451`)

	, currency(`GBP`)

	, sender_name( `De La Rue Currency` )
	
	, delivery_email( `michelle.lugsden@uk.delarue.com` )
	, buyer_email( `michelle.lugsden@uk.delarue.com` )
	
	, i_order_requested_by( `Michelle Lugsden` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  gen1_uk_address( [ delivery ] )
	  
	, delivery_country_code( `GBR` )
	
] ).

%=======================================================================
i_rule_cut( delivery_start_rule, [ 
%=======================================================================

	  xor( [ [ q0n(line), delivery_start_line ]
	  
		, [ q(0,3,line), read_ahead( alternate_delivery_start_line ) ]
	] )

	, q(2,2, [ qn0( gen_line_nothing_here( [ delivery_left_margin(end), 10, 10 ] ) ), delivery_contact_line ] )

] ).

%=======================================================================
i_line_rule( delivery_start_line, [
%=======================================================================

	  q0n( [ dummy(s1), tab ] )
	  
	, read_ahead( [ `Consign`, `To` ] )

	, delivery_left_margin(s1)

	, check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 10, 40 ) )
	
	, trace( [ `found margin` ] )
	
] ).

%=======================================================================
i_line_rule( alternate_delivery_start_line, [
%=======================================================================

	  q0n( [ dummy(s1), tab ] )
	  
	, read_ahead( [ `De`, `La`, `Rue`, newline ] )

	, delivery_left_margin(s1)

	, check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 10, 20 ) )
	
	, trace( [ `found margin` ] )
	
	, set( alternate )
	
] ).

%=======================================================================
i_line_rule_cut( delivery_contact_line, [
%=======================================================================

	  nearest_word( delivery_left_margin(start), 10, 10 )
	  
	, q10( [ without( i_site_delivery_point )
		, peek_fails( [ `De`, `La` ] )
		, read_ahead( generic_item( [ i_site_delivery_point, s1 ] ) )
	] )
	
	, generic_item( [ delivery_contact, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or( [ with( delivery_postcode )

		, [ `Registered` ]
		
		, [ q0n( [ dummy(s1), tab ] ), `Telephone` ]
		
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,20,line)
	  
	, generic_horizontal_details( [ [ or( [ [ `Order`, `No` ], `Purchase` ] ) ], order_number, s1
		, [ check( order_number = Ord ), check( q_regexp_match( `^.*\\d.*$`, Ord, _ ) ) ]
	] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Date` ], invoice_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER REQUESTED BY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_i_order_requested_by, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Ordered`, `by`, `:` ], i_order_requested_by, s1 ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_totals, [
%=======================================================================

	  q0n( [ dummy(s1), tab ] )
	  
	, or( [ [ `Total`, `Order`, `Value`, tab ]
	
		, [ `Sub`, `Total`, dummy(s1), tab ]
	] )
	
	, set( regexp_cross_word_boundaries )

	, read_ahead( generic_item( [ total_invoice, d ] ) )
	
	, generic_item( [ total_net, d ] )
	
	, clear( regexp_cross_word_boundaries )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, q0n( [

		  or([ line_invoice_rule

			, line

		])

	] ), line_end_line	

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `Nominal`, `Code` ] ), header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ `When`, `supplying`, `goods` ] 
	
		, [ `Total`, `Order`, `Value` ]
		
		, [ `Delivery`, `By` ]
		
		, [ `Sub`, `Total`, `Amount` ]
		
		, [ `Please`, `acknowledge` ] 
		
		, [ `All`, `Deliveries` ] 
		
		, [ `Buyer`, newline ]
		
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  read_ahead( line_invoice_line )
	  
	, read_description_rule( [ -300, 0, or( [ line_check_line, line_end_line ] ) ] )

	, q10( [ with( invoice, i_site_delivery_point, Site )
		, l_site_delivery_point( Site )
	] )
	
	, l_order_requested_by( `Michelle Lugsden` )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [ 
%=======================================================================
	
	generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_quantity_uom_code, w, q10( tab ) ] )
	
	, generic_item( [ dummy_descr, s1, tab ] )

	, generic_item( [ some, date, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )

	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ALTERNATE LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_alternate_invoice_lines, [
%=======================================================================

	  line_alternate_header_line

	, q0n( [

		  or([ line_alternate_invoice_rule

			, line

		])

	] ), line_end_line	

] ).

%=======================================================================
i_line_rule_cut( line_alternate_header_line, [ `Ref`, tab, `Quantity`, tab, header ] ).
%=======================================================================

%=======================================================================
i_rule_cut( line_alternate_invoice_rule, [
%=======================================================================

	  read_ahead( line_alternate_invoice_line )
	  
	, read_description_rule( [ -110, 500, or( [ line_check_line, line_end_line ] ) ] )
	
	, line_values_line

	, q10( [ with( invoice, i_site_delivery_point, Site )
		, l_site_delivery_point( Site )
	] )

] ).

%=======================================================================
i_line_rule_cut( line_alternate_invoice_line, [ 
%=======================================================================
	
	generic_item_cut( [ line_no, d, tab ] )
	
	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_quantity_uom_code, w, q10( tab ) ] )
	
	, generic_item( [ dummy_descr, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [ 
%=======================================================================
	
	generic_item_cut( [ line_unit_amount, d, `GBP` ] )
	
	, dummy(s1), tab
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_check_line, [ q0n(anything), or( [ some(date), `GBP` ] ) ] ).
%=======================================================================
i_rule_cut( read_description_rule( [ Left, Right, End ] ), [ 
%=======================================================================

	or( [ [ gen1_parse_text_rule( [ Left, Right, End, line_item, Format ] )
			, arco_descr_lookup_rule
		]
		
		, [ gen1_parse_text_rule( [ Left, Right, End, line_item, Format ] )
		
			, check( captured_text = Descr )
			, line_descr( Descr )	
			, trace( [ `Line Description from Page`, line_descr ] )
			
		]
		
		, [ gen1_parse_text_rule( [ Left, Right, End ] )
		
			, check( captured_text = Descr )
			, line_descr( Descr )
			, line_item( `Missing` )
			, trace( [ `Item missing, description from page`, line_descr ] )
			
		]
		
	] )

] ):- i_user_data( arco_item_format( Format ) ).

%=======================================================================
i_rule_cut( arco_descr_lookup_rule, [
%=======================================================================

	  check( i_user_check( retrieve_from_cache, line_item, DESCR ) )

	, line_descr( DESCR )

	, trace([`line descr from lookup`, line_descr])

] ).

%=======================================================================
i_user_check( retrieve_from_cache, ITEM, DESCR )
%-----------------------------------------------------------------------
:-
%=======================================================================

	lookup_cache( `arco.csv`, `arco`, `item`, ITEM, `description`, DESCR )

. %end%

address_lookup( `de la rue`, `ne110sq`, `kingsway south team valley trading estate gateshead ne11 0sq`, `704949` ).
address_lookup( `de la rue`, `ne110sq`, `accounts payable department kingsway south team valley trading estate gateshead ne11 0sq`, `105294` ).
address_lookup( `de la rue`, `ne110sq`, `security print kingsway south team valley trading estate gateshead ne11 0sq`, `740124` ).