%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MASTERS HOME IMPROVEMENT AUSTRALIA PTY LTD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( au_masters, `19 August 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

% i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
% i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, gen_capture( [ [ `Purchase`, `Order`, `No`, `:` ], order_number, s1, newline ] )
	, gen_capture( [ [ `Order`,`Date`, `:` ], invoice_date, date, newline ] )
	, gen_capture( [ [ `Special`, `Instructions`, `:` ], customer_comments, s1, newline ] )
	
	, get_invoice_type
	
	, get_delivery_details
	
	, get_duplicates
	
	, get_delivery_address

	, get_invoice_lines
	
	, gen_capture( [ [ `Total`, `Value`, `(`, `Ex`, `.`, `GST`, `)`, `:` ], total_net, d, newline ] )
	, gen_capture( [ [ `Total`, `Value`, `(`, `Ex`, `.`, `GST`, `)`, `:` ], total_invoice, d, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `AU-ADAPTRI` )

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )
	
	, or( [ 
	  [ test(test_flag), suppliers_code_for_buyer(`10493821`) ]    %TEST
	    , suppliers_code_for_buyer(`20144025`)                   %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply(`SY`)
	
	, sender_name( `Masters Home Improvement Australia Pty Ltd.` ) % 2 branches of BHP use these rules.
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Contact`,`Name`, `:`, tab ], delivery_contact, s1, newline ] )
	
	, check(delivery_contact(end) > 0)
	
	, q01(line)
	
	, generic_horizontal_details( [ [ `Phone`, `:`, tab ], delivery_ddi, s1, newline ] )

	, q01(line)
	
	, generic_horizontal_details( [ [ `Email`, `:`, tab ], delivery_email, s1, newline ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE TYPE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_type, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Version`, `Number`, `:` ], invoice_typex, d, newline ] )
	
	, q10( [ check( q_sys_comp_str_gt(invoice_typex, `1`) ), invoice_type( `ZE` ) ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DUPLICATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_duplicates, [
%=======================================================================

	q10( [
	
		with(invoice, delivery_ddi, DDI)
		
		, buyer_ddi(DDI)
		
		, trace( [ buyer_ddi ] )
		
	] )
	
	, q10( [
	
		with(invoice, delivery_contact, Cont)
		
		, buyer_contact(Cont)
		
		, trace( [ buyer_contact ] )
		
	] )
	
	, q10( [
	
		with(invoice, delivery_email, Email)
		
		, buyer_email(Email)
		
		, trace( [ buyer_email ] )
		
	] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	q0n(line)

	, delivery_start_line
	
	, q(0,2,line)
	
	, delivery_street_line
	
	, q(0,2,line)
	
	, delivery_city_line
	
	, q(0,2,line)
	
	, delivery_postcode_line
	
] ).

%=======================================================================
i_line_rule( delivery_start_line, [
%=======================================================================
	
	delivery_party(`Masters Home Improvement Aust P/L`)

	, `Delivery`, `to`, `Location`, `:`, q10(tab)
	
	, trace( [ `Found the text` ] )
	
	, generic_item( [ delivery_left_margin, s1 ] )
	
	, check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 10, 10 ) )

] ).

%=======================================================================
i_line_rule( delivery_street_line, [
%=======================================================================

	nearest(delivery_left_margin(start), 10, 10)
	
	, generic_item( [ delivery_street, s1 ] )

] ).

%=======================================================================
i_line_rule( delivery_city_line, [
%=======================================================================

	nearest(delivery_left_margin(start), 10, 10)
	
	, generic_item( [ delivery_cityx, s1 ] )
	
	, check( delivery_cityx = City )
	
	, check( string_to_upper( City, CityUpper ) )
	
	, delivery_city( CityUpper )

] ).

%=======================================================================
i_line_rule( delivery_postcode_line, [
%=======================================================================

	nearest(delivery_left_margin(start), 10, 10)
	
	, generic_item( [ delivery_state, s ] )
	
	, generic_item( [ delivery_postcode, d, gen_eof ] )

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

	, qn0( [ peek_fails( line_end_line )

		, or( [ 
		
			line_invoice_rule

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`No`, tab, read_ahead( [ `Item`, `Code` ] ), item_hook(s1), tab
	
	, read_ahead( [ `Item`, `Code` ] ), traders_hook(s1)

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `Currency`, `:`
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
	, line_invoice_line1
	
	, q10( [ or( [ check( line_item = `FREIGHT` ), check( i_user_check( check_descr_for_freight, line_descr ) ) ] )
	
		, trace( [ `freight line, ignoring` ] )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  generic_item( [ line_order_line_number, d, tab ] )
	
	, q10( generic_item( [ dummy, s1, [ tab, check( dummy(start) < item_hook(start) ) ] ] ) )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, q10( generic_item( [ line_item, s1, [ tab, check( line_item(start) >= traders_hook(start) ) ] ] ) )
		
	, generic_item( [ dummy, d, tab ] )
	
	, generic_item( [ dummy, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ dummy, d, tab ] )
	
	, generic_item( [ line_net_amount, d, tab ] )
	
	, generic_item( [ line_total_amount_x, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line1, [
%=======================================================================
   
	`Item`, `Description`, `:`, q10( tab )
	
	, generic_item( [ line_descr, s1, newline ] )
	
] ).

%-----------------------------------------------------------------------
i_user_check( check_descr_for_freight, Descr )
%-----------------------------------------------------------------------
:-
	string_to_upper( Descr, Descr_U ),
	sys_string_split( Descr_U, ` `, Descr_list ),
	q_sys_member( Word, Descr_list ),
	q_sys_sub_string( Word, _, _, `FREIGHT` ),
	trace( `description contains freight` ),
	!
.
