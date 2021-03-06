%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FI NESTE OIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fi_neste_oil, `28 May 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_pdf_parameter( x_tolerance_100, 100 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_buyer_contact
	
	, get_buyer_ddi
	
	, get_buyer_fax
	
	, get_buyer_email

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `FI-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`3300`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, type_of_supply( `S0` )
	, suppliers_code_for_buyer( `18169088` )
	
	, delivery_party( `NESTE OIL OYJ` )
	
	, sender_name( `Neste Oil Oyj` )

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_vertical_details( [ [ `Ostotilaus` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  invoice_date( TodayString ), trace( [ `Today's Date`, TodayString ] )
	
] ):- date_get( today, Today ), date_string( Today, `d/m/y`, TodayString ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,30,line), delivery_header_line

	, q(0,3,line)

	, delivery_thing( [ delivery_street ] )
	
	, qn0( gen_line_nothing_here( [ hook(start), 10, 10 ] ) )
	
	, delivery_city_and_postcode_line

] ).


%=======================================================================
i_line_rule( delivery_header_line, [ q0n( [ dummy(s1), tab ] ), read_ahead( [ `Toimitusosoite` ] ), hook(w)] ).
%=======================================================================
i_rule( delivery_thing( [ Variable ] ), [ qn0( gen_line_nothing_here( [ hook(start), 10, 10 ] ) ), delivery_thing_line( [ Variable ] ) ] ).
%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [
%=======================================================================

	nearest( hook(start), 10, 10 )
	
	, generic_item( [ Variable, s1 ] )

] ).

%=======================================================================
i_line_rule( delivery_city_and_postcode_line, [
%=======================================================================

	nearest( hook(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,10,line)
	  
	, generic_vertical_details( [ [ `Käsittelijä` ], buyer_contact, s1 ] )

] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ at_start, or( [ `Puh`, `GSM` ] ) ], buyer_ddi, s1 ] )

] ).

%=======================================================================
i_rule( get_buyer_fax, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ at_start, `Telefaksi` ], buyer_fax, s1 ] )

] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ at_start, `sähköposti` ], buyer_email, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  qn0(line)

	, generic_horizontal_details( [ [ at_start, `Summa`, tab, `EUR`, set( regexp_cross_word_boundaries ) ], 500, total_net, d ] )

	, clear( regexp_cross_word_boundaries )
	, check( total_net = Net )
	, total_invoice( Net )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `Sopimusviite`, tab, `Kauppanimi` ] ), header(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ `Neste`, `Oil` ]
	
		, [ `Summa` ]

		, [ dummy(w), check( not( dummy(page) = header(page) ) ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_descr_line
	  
	, line_date_line

	, q10( line )
	
	, line_total_line
	, q10( [ check( q_sys_comp_str_eq( line_net_amount, `0` ) )
		, line_type( `ignore` )
	] )

] ).

%=======================================================================
i_line_rule( line_descr_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )

	, q10( [ dummy(s1), tab, check( dummy(end) < -210 ) ] )
	
	, q10( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ), set( got_item ) ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d ] )
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, set( regexp_cross_word_boundaries )
	, generic_item( [ line_unit_amount, d, newline ] )
	, clear( regexp_cross_word_boundaries )
	
] ).

%=======================================================================
i_line_rule( line_date_line, [ q01( [ dummy(s1), tab ] ), generic_item( [ line_original_order_date, date ] ) ] ).
%=======================================================================
i_line_rule( line_total_line, [
%=======================================================================

	  or( [ [ peek_fails( test( got_item ) )
			, or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
				, line_item( `Missing` )
			] )
		]
		
		, test( got_item )
	] )
	
	, q10( [ append( line_descr(s1), ` `, `` ), tab ] )
	
	, set( regexp_cross_word_boundaries )
	, generic_item( [ line_net_amount, d, newline ] )
	, clear( regexp_cross_word_boundaries )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).