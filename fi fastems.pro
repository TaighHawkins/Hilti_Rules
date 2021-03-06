%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FI FASTEMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fi_fastems, `24 October 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_scfb

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_delivery_contact

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
	
	, sender_name( `Fastems Oy` )

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_scfb, [ suppliers_code_for_buyer( `10726206` ) ] ):- grammar_set( test_flag ).
%=======================================================================	
i_rule( get_scfb, [
%=======================================================================	  
	  
	  q(0,10,line), generic_vertical_details( [ [ `Asiakasnr`, `-`, `Kund` ], suppliers_code_for_buyer, s1 ] )
	
] ):- not( grammar_set( test_flag ) ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_vertical_details( [ [ `Tilausnro`, `-`, `Beställning` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ invoice_date, date ] )
	
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

	, delivery_thing( [ delivery_street ] )
	
	, qn0( gen_line_nothing_here( [ hook(start), 10, 10 ] ) )
	
	, delivery_city_and_postcode_line

] ).


%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( [ `Toimitusosoite` ] ), hook(w)] ).
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
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,10,line)
	  
	, generic_vertical_details( [ [ `Käsittelijä`, `-`, `Handläggare` ], delivery_contact, s1 ] )
	
	, check( delivery_contact = Con )
	, buyer_contact( Con )

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
	  
	, set( regexp_cross_word_boundaries )

	, generic_horizontal_details( [ [ at_start, `Yhteensä`, dummy(s1), tab, `EUR` ], 500, total_net, d ] )

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
i_line_rule_cut( line_header_line, [ read_ahead( [ `Rad`, `Lev`, `.`, `kod` ] ), header(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ `Yhteensä` 

		, [ dummy(w), check( not( dummy(page) = header(page) ) ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_descr_line
	  
	, line_values_line

	, count_rule

] ).

%=======================================================================
i_line_rule( line_descr_line, [
%=======================================================================

	  generic_item_cut( [ line_no, d, q10( tab ) ] )

	, or( [ [ generic_item( [ line_descr, s, generic_item( [ line_item, [ begin, q(dec,4,10), end ], newline ] ) ] )
			, set( got_item )
		]
		
		, generic_item( [ line_descr, s1, newline ] )

	] )
	
] ).

%=======================================================================
i_line_rule( line_values_line, [
%=======================================================================

	  or( [ test( got_item )
	  
		, [ peek_fails( test( got_item ) )
		
			, or( [ generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], q10( tab ) ] ), line_item( `Missing` ) ] )
			
		]
		
	] )
	
	, or( [ [ without( customer_comments ), generic_item( [ customer_comments, s1, tab ] ) ]
	
		, [ with( customer_comments ), generic_item( [ dummy_comments, s1, tab ] ) ]
		
	] )
	
	, q01( [ dummy(s1), tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).