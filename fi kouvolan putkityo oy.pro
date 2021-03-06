%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FI KOUVOLAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fi_kouvolan, `09 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_delivery_contact
	
	, get_shipping_instructions

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

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10726206` ) ]    %TEST
	    , suppliers_code_for_buyer( `14445480` )                      %PROD
	]) ]
	
	, sender_name( `Kouvolan Putkityö Oy` )

	, set( reverse_punctuation_in_numbers )
	, set( leave_spaces_in_order_number )
	, set( enable_duplicate_check )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `TILAUS` ], order_number, s1 ] )
	  
	, q(0,20,line), generic_horizontal_details( [ [ at_start, `Kohde` ], 150, order_number_x, s1 ] )
	
	, check( order_number_x = X )
	
	, append( order_number( X ), ` / `, `` )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `Tilauspvm` ], invoice_date, date ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,200,line), delivery_header_line

	, delivery_thing( [ delivery_party ] )
	
	, q10( delivery_thing( [ delivery_dept ] ) )
	
	, q01( or( [ delivery_ddi_and_contact, delivery_thing( [ delivery_address_line ] ) ] ) )

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

%=======================================================================
i_line_rule_cut( delivery_ddi_and_contact, [
%=======================================================================

	nearest( hook(start), 10, 10 )
	
	, read_ahead( [ dum(d), dum(d) ] )
	
	, generic_item( [ delivery_ddi, sf, read_ahead( some(f([q(alpha,1,20)])) ) ] )
	
	, generic_item( [ delivery_contact, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,10,line)
	  
	, generic_horizontal_details( [ `Ostaja`, 200, delivery_contact_x, s1 ] )
	
	, check( delivery_contact_x = Con_x )
	, check( sys_string_split( Con_x, ` `, Con_Split ) )
	, check( sys_reverse( Con_Split, Con_Rev ) )
	, check( wordcat( Con_Rev, Con ) )
	
	, buyer_contact( Con )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	q(0,30,line), generic_horizontal_details( [ [ `Vastaanottaja`, `:` ], shipping_instructions, s1, newline ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q(0,200,line)
	  
	, generic_horizontal_details( [ [ at_start, `Yhteensä`, dummy(s1) ], 700, total_net, d ] )

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
			  
			, line_defect_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `Nro`, tab, `Kuvaus` ] ), header(w) ] ).
%=======================================================================
i_line_rule_cut( line_header_line, [ q0n(anything), some(date), force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ `Yhteensä` 
	
		, [ q0n( [ dummy(s1), tab ] ), `Facturatie` ]
		
		, [ `Kouvolan`, `Putkityö`, `Oy` ]
	
		, [ dummy(w), check( not( dummy(page) = header(page) ) ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  or( [ line_invoice_line
	  
		, [ line_item_and_descr_line
		
			, line_values_line
			
			, line_continuation_line
			
		]
		
		, [ generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] )
		
			, set( item_needed ), line_values_line
			
			, line_continuation_line
			
			, clear( item_needed )
		
		]
		
	] )
	  
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [ item_and_descr_rule, values_rule ] ).
%=======================================================================
i_line_rule_cut( line_item_and_descr_line, [ item_and_descr_rule ] ).
%=======================================================================
i_line_rule_cut( line_values_line, [ values_rule ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_rule( item_and_descr_rule, [
%=======================================================================

	  generic_item_cut( [ line_item, [ q(alpha("HIL"),0,2), begin, q(dec,3,10), end ], q10( tab ) ] )

	, generic_item( [ line_descr, s1, gen_eof ] )

] ).

%=======================================================================
i_rule( values_rule, [
%=======================================================================

	  or( [ [ peek_fails( test( item_needed ) ) ]
	  
		, [ test( item_needed ), generic_item( [ line_item, [ q(alpha("HIL"),0,2), begin, q(dec,3,10), end ], tab ] ) ]
		
	] ), generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item_cut( [ line_quantity_uom_code, w, q10( tab ) ] )

	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )

	, generic_item( [ line_percent_discount, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d ] )
	
	, or( [ newline
		, generic_item( [ line_original_order_date, date, newline ] )
	] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).