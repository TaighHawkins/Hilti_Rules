%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GENERAL DATATECH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_general_datatech, `11 May 2015` ).

i_date_format( `m/d/y` ).

i_format_postcode( X,X ).

i_pdf_paramater( x_tolerance_100, 100 ).

i_op_param( xml_empty_tags( `AUGRU` ), _, _, _, `ZED` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, gen_capture( [ [ `PO`, `#`, tab ], order_number, s1, newline ] )
	, gen_capture( [ [ `Date`, tab ], invoice_date, date, newline ] )

	, get_delivery_location
	
	, get_email_address
	
	, get_invoice_lines

	, gen_capture( [ [ `Total`, tab, `$` ], total_net, d, newline ] )
	, gen_capture( [ [ `Total`, tab, `$` ], total_invoice, d, newline ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%
	
	, sender_name( `General Datatech` )
	
	, suppliers_code_for_buyer( `10823661` )
	
	, set( no_pc_cleanup )
	, cost_centre(`Standard`)
	, type_of_supply(`01`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_email_address, [ 
%=======================================================================

	delivery_email(FROM)

] ):- i_mail( from, FROM ) .

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	q0n(line)

	, delivery_header_line
	
	, trace( [ `Here` ] )
	
	, q(0,2,line)
	
	, delivery_party_line
	
	, trace( [ `Here` ] )
	
	, q(0,2,line)
	
	, delivery_dept_line
	
	, trace( [ `Here1` ] )
	
	, q(0,2,line)
	
	, delivery_street_line
	
	, trace( [ `Here2` ] )
	
	, q(0,2,line)
	
	, delivery_contact_line
	
	, trace( [ `Here3` ] )
	
	, q(0,2,line)
	
	, delivery_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	q0n(anything), read_ahead( [ `Ship`, `To` ] ), header(w)
	
] ).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ delivery_party, s1 ] ), newline
	
] ).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ delivery_dept, s1 ] ), newline
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), delivery_street(s1), newline
	
] ).

%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ delivery_contact, sf ] )
	
	, q10( `-` ), q10( [ delivery_ddix( f( [ begin, q(dec,3,3), q(other("-."),1,1), q(dec,3,3), q(other("-."),1,1), q(dec,4,4), end ] ) ), trace( [ `Delivery DDI`, delivery_ddi ] ) ] )
	
	, newline
	
	, check( string_string_replace( delivery_ddix, `.`, `-`, DDI ) )
	
	, delivery_ddi( DDI )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), delivery_city(s)
	
	, `,`, delivery_state(s)
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, q10( append( delivery_postcode(f( [ begin, q(other("-"),1,1), q(dec,4,4), end ] ) ), ``, `` ) )
	
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

	, qn0( [ peek_fails(line_end_line)

		, or( [ 
		
			get_line_invoice

			, line_continuation_line , line
			])

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Qty`, tab, `Part`, `Number`, tab, `Manuf`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	or( [ 
	
		[ `TOTALE` ]

		, [	`ORDINE`, q10( `INTERNO` ), `N`, `°` ]
		
		, [ `1`, `.`, `RIBA`, `con`, `scadenza` ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( get_line_invoice, [
%=======================================================================
	
	generic_item( [ line_quantity, d, q10(tab) ] )
	
	, generic_item( [ line_item, s1, tab ] )

	, generic_item( [ line_descr, s, q10(tab) ] )
	
	, `$`, generic_item( [ line_unit_amount, d, tab ] )
	
	, `$`, generic_item( [ line_net_amount, d, tab ] )
	
	, generic_item( [ line_original_order_date, date, newline ] )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	append( line_descr(s1), ` `, ``), newline
	
] ).



%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, string_string_replace( Delivery_L, `/`, ` / `, Delivery_Rep )
	, sys_string_split( Delivery_Rep, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport` ] )
	, trace( `delivery line, line being ignored` )
.

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).