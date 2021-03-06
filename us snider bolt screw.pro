%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US SNIDER BOLT SCREW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_snider_bolt_screw, `28 July 2015` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_date_format( `m/d/y` ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

bespoke_e1edp19_segment( [ `098`, line_item ] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, gen_vert_capture( [ [ `Purchase`, `Order`, `Number`, newline ], `Order`, start, order_number, s1, newline ] )
	, gen_vert_capture( [ [ `Date`, tab, `Page` ], invoice_date, date ] )
	
	, gen_vert_capture( [ [ `Required`, `Date` ], `Required`, end, delivery_date, date ] )
	
	, get_delivery_address

	, get_emails
	
	, get_contacts
	
	, get_invoice_lines
	
	, gen_capture( [ [ `TOTAL`, `:` ], 200, total_net, d, newline ] )
	, gen_capture( [ [ `TOTAL`, `:` ], 200, total_invoice, d, newline ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

%%%%%%%%% FIXED %%%%%%%%%

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `US-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`6000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

%%%%%%%%%%%%%%%%%%%%%%%%%

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11265768` ) ]    %TEST
	    , suppliers_code_for_buyer( `14730108` )                      %PROD
	]) ]
	
	, sender_name( `Snider Bolt & Screw` )
	
	, delivery_party( `SNIDER BOLT & SCREW INC` )
	
	, type_of_supply( `01` )
	
	, cost_centre( `Standard` )
	
	, set( no_uom_transform )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q0n(line)
	
	, generic_horizontal_details( [ [ `Ship`, `To`, `:`, newline ] ] )
	
	, q(0,5,line)
	
	, delivery_street_line
	
	, q01(line)
	
	, delivery_city_state_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_street_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	
	, generic_item( [ delivery_street, s1, newline ] )

] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )

	, generic_item( [ delivery_city, sf, `,` ] )
	
	, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ], newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET EMAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_emails, [
%=======================================================================

	  buyer_email( From ), delivery_email( From )
	
	, trace( [ `Email`, From ] )

] ):- i_mail( from, From ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [
%=======================================================================

	  q0n(line)
	
	, generic_vertical_details( [ [ `Buyer`, `Name` ], contact, s1 ] )
	
	, check( i_user_check( clean_contact, contact, Contact ) )
	
	, buyer_contact( Contact ), delivery_contact( Contact )
	, trace( [ `contact`, Contact ] )

] ).

%-----------------------------------------------------------------------
i_user_check( clean_contact, Contact_in, Contact_out )
%-----------------------------------------------------------------------
:-
	string_to_upper( Contact_in, Contact_U ),
	strip_string2_from_string1( Contact_U, `,`, Contact ),
	sys_string_split( Contact, ` `, [ Surname, First_name ] ),
	strcat_list( [ First_name, ` `, Surname ], Contact_out ),
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [
		
			line_invoice_rule
			
			, line
		
		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Unit`, `Size`, tab, q10( [ `Description`, tab ] ), `Unit`, `Size`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	  `TOTAL`, `:`, tab
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================
	
	  line_invoice_line
	
	, line_descr_line
	
	, q01(line)
	
	, line_item_line
	
	, line_quantity_uom_code( `PC` )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
	
	  generic_no( [ line_order_line_number, d, tab ] )
	
	, generic_no( [ line_quantity, d ] )
	
	, generic_item( [ not_uom_code_, s1, tab ] )
	
	, generic_item( [ line_original_order_date, date, q10(tab) ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_no( [ line_unit_amount, d ] )
	
	, word, tab
	
	, generic_no( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================
	
	  generic_no( [ unit_size_, d, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_no( [ unit_size_, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================
	
	  q0n(word), `PN`, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ), q0n(word), newline
	
] ).