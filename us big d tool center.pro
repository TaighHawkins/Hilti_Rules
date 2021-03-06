%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US BIG D TOOL CENTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_big_d_tool_center, `25 June 2015` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_date_format( _ ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ):- grammar_set( no_more_delivery ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

bespoke_e1edp19_segment( [ `098`, line_item ] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, gen_vert_capture( [ [ `PURCHASE`, `ORDER`, newline ], `PURCHASE`, end, order_number, s1, newline ] )
	, gen_capture( [ [ gen_beof, `Date`, `:` ], invoice_date, date, newline ] )
	
	, get_delivery_address
	
	, get_suppliers_code_for_buyer
	
	, gen_vert_capture( [ [ `BUYER`, newline ], buyer_contact, s1 ] )
	, gen_vert_capture( [ [ `BUYER`, newline ], delivery_contact, s1 ] )

	, get_emails
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_invoice_lines
	
	, gen_capture( [ [ gen_beof, `SUBTOTAL` ], 200, total_net, d, newline ] )
	, gen_capture( [ [ gen_beof, `SUBTOTAL` ], 200, total_invoice, d, newline ] )
	
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
	
	, sender_name( `Big D Tool Center` )
	
	, type_of_supply( `01` )
	
	, cost_centre( `Standard` )
	
	, set( enable_duplicate_check )
	
	, custom_notification_address( `hiltiselect@hilti.com` )

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
	
	, generic_horizontal_details( [ [ `SHIP`, `TO` ], delivery_left_margin, s1 ] )
	
	, delivery_street_line
	
	, or( [
	
		test( no_more_delivery )
		
		, [ delivery_city_state_line, delivery_postcode_line ]
	
	] )

] ).

%=======================================================================
i_line_rule( delivery_street_line, [
%=======================================================================

	  nearest( delivery_left_margin(start), 10, 10 )
	  
	, or( [
	
		[ `2535`, `Irving`, `Blvd`, delivery_note_number( `19066809` )
			, trace( [ `delivery_note_number`, delivery_note_number ] )
			, set( no_more_delivery )
		]
	
		, generic_item( [ delivery_street, s1, newline ] )
		
	] )

] ).

%=======================================================================
i_line_rule( delivery_city_state_line, [
%=======================================================================

	  nearest( delivery_left_margin(start), 10, 10 )

	, generic_item( [ delivery_city, sf, `,` ] )
	
	, or( [
	
		[ `Texas`, delivery_state( `TX` ) ]
		
		, generic_item( [ delivery_state, s1 ] )
		
	] )

] ).

%=======================================================================
i_line_rule( delivery_postcode_line, [
%=======================================================================

	  nearest( delivery_left_margin(start), 10, 10 )

	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `SUPPLIER`, `CONTACT` ] ] )
	
	, suppliers_code_for_buyer_line

] ).

%=======================================================================
i_line_rule( suppliers_code_for_buyer_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	
	, q0n(word), `#`, generic_item( [ suppliers_code_for_buyer, s1 ] )

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

	  `LINE`, tab, `QUANTITY`, `UOM`, tab, `PRODUCT`, `CODE`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	  or( [
	
		[ `Continued`, `to` ]
		
		, [ `SUBTOTAL`, tab ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================
	
	  line_invoice_line
	
	, generic_line( [ [ generic_item( [ line_descr, s1 ] ), q01( [ tab, a(s1) ] ), newline ] ] )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
	
	  generic_no( [ line_no_, d, tab ] )
	
	, generic_no( [ line_quantity, d ] )
	
	, or( [
	
		[ `EA`, line_quantity_uom_code( `PC` ), trace( [ `line_quantity_uom_code`, line_quantity_uom_code ] ) ]
		
		, generic_item( [ dummy_, w, q10(tab) ] )
		
	] )
	
	, generic_item( [ line_item, [ q(alpha("HI"),2,2), begin, q(dec,4,10), end, q(any,0,5) ], tab ] )
	
	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================
	
	  q0n(word), `PN`, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ), q0n(word), newline
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).