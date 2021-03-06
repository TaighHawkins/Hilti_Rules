%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BOUYGUES UK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( bouygues_uk, `15 July 2015` ).

i_pdf_parameter( same_line, 4 ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_invoice_date
	
	, get_delivery_party

	, get_delivery_details
	
	, get_buyer_email
	
	, get_buyer_contact
	
	, get_buyer_ddi

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

	, buyer_registration_number( `GB-BOUYGUK` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `17471815` )

	, sender_name( `BOUYGUES (UK) LTD` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Purchase`, `Order`, `N`, `°` ],order_number, s1 ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Date`, `:` ], invoice_date, date ] ) 
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [ q(0,25,line), generic_horizontal_details( [ [ `Email`, `:` ], buyer_email, s1 ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	q(0,25,line), generic_vertical_details( [ [ `Order`, `Placed`, `By` ], buyer_contact_x, s1 ] )
	
	, check( buyer_contact_x = Con_Rev )
	
	, check( sys_string_split( Con_Rev, ` `, Con_Rev_List ) )
	
	, check( sys_reverse( Con_Rev_List, Con_List ) )
	
	, check( wordcat( Con_List, Con ) )
	
	, buyer_contact( Con )

] ).

%=======================================================================
i_rule( get_buyer_ddi, [ q(0,25,line), generic_horizontal_details( [ [ `Mobile`, `:` ], buyer_ddi, s1 ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q(0,50,line), generic_line( 2, 0, 500, [ [ `Site`, `Reference`, q0n(word), generic_item( [ delivery_location, [ begin, q(dec,6,6), end ] ] ) ] ] )
	
] ).

%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [ nearest( hook(start), 5, 15 ), generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
ii_rule( get_delivery_details, [
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ read_ahead( [ `Delivery`, `address`, `:` ] ), hook, s1 ] )
	  
	, qn0( gen_line_nothing_here( [ hook(start), 5, 15 ] ) ), delivery_thing_line( [ street_2 ] )
	
	, qn0( gen_line_nothing_here( [ hook(start), 5, 15 ] ) ), delivery_thing_line( [ delivery_street ] )
	
	, check( street_2 = Street )
	
	, delivery_street( Street )
	
	, qn0( gen_line_nothing_here( [ hook(start), 5, 15 ] ) )
	
	, q01(line), delivery_city_and_postcode_line

] ).

%=======================================================================
i_rule( get_delivery_party, [
%=======================================================================

	  q(0,3,line), generic_vertical_details( [ [ `Order`, `issued`, `by` ], delivery_party, sf, `-` ] )

] ).

%=======================================================================
i_line_rule( delivery_city_and_postcode_line, [
%=======================================================================

	  nearest( hook(start), 5, 25 )
	  
	, or( [ generic_item( [ delivery_city, sf, generic_item( [ delivery_postcode, pc ] ) ] )
	
		, generic_item( [ delivery_postcode, pc  ] )
		
	] )
	
	, q10( [ check( delivery_postcode = `EC2A3PQ` ), invoice_type( `ZE` ) ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), set( regexp_cross_word_boundaries )
	  
	, generic_horizontal_details( [ [ `Total`, `ex`, `.`, `VAT` ], 150, total_net, d, [ `GBP`, newline ] ] )
	
	, clear( regexp_cross_word_boundaries )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [ [ with( invoice, delivery_charge, Charge )
	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			
			, net_subtotal_2( Charge )
			
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )
		
			, check( total_net = Net_1 )
			
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `Purchaser`, `Copy` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 
		
			  line_invoice_rule
	
			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `CODE`, newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Payment`, `terms` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, q(2,0, line_dummy_line )
	
	, or( [ [ peek_fails( test( transport ) )
	
			, line_descr_line

			, q0n( line_continuation_line )
			
			, or( [ [ peek_fails( test( got_item ) ), line_item_line ]
			
				, [ peek_ahead( or( [ line_check_line, line_end_line ] ) )
				
					, or( [ test( got_item ), line_item( `Missing` ) ] )
					
				]
				
			] )
			
		]
	
		, [ test( transport )
		
			, line_type( `ignore` )
			
			, check( line_net_amount = Net )
			
			, delivery_charge( Net )
			
		]
		
	] )
%	30th January	
	, line_quantity_uom_code( `PAC` )
	
	, clear( transport )
	
	, clear( got_item )
	
] ).

%=======================================================================
i_line_rule_cut( line_check_line, [ or( [ [ qn0(anything), some(date) ], [ test( got_item ), `Supplier` ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_dummy_line, [ generic_item( [ dummy, s1, [ check( dummy(start) < -300 ), newline ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_descr_line, [ 
%=======================================================================

	  q10( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], q10( `-` ) ] ), set( got_item ) ] )
	  
	, generic_item( [ line_descr, s1, newline ] ) 
	
] ).


%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ) ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [ 
%=======================================================================

	or( [ [ `Supplier`, `Reference`, tab ]
	
		, [ `Item`, `No`, `.` ]
		
	] )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], newline ] ) 

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )
	  
	, q01( some_num(d) )

	, q10( generic_item( [ some_code, w, tab ] ) )
	
	, q10( [ read_ahead( [ q0n(word), `TRANSPORT` ] ), set( transport ) ] )

	, generic_item_cut( [ line_descr_x, s1, tab ] )

	, generic_item_cut( [ line_quantity, d ] )
	
	, generic_item_cut( [ line_quantity_uom_code_x, s1, tab ] )

	, set( regexp_cross_word_boundaries )
	
	, generic_item( [ line_unit_amount_x, d, q10( tab ) ] )

	, generic_item( [ line_net_amount, d, q10( tab ) ] )
	
	, clear( regexp_cross_word_boundaries )
	
	, generic_item_cut( [ line_original_order_date, date, newline ] )
	
] ).

%=======================================================================
i_analyse_line_fields_first( LID )
%-----------------------------------------------------------------------
:-	i_analyse_descriptions_for_quantities_( LID ).
%=======================================================================

%=======================================================================
i_analyse_descriptions_for_quantities_( LID )
%-----------------------------------------------------------------------
:-
%=======================================================================

	result( _, LID, line_descr, Descr )
	, result( _, LID, line_quantity, Quantity )
	
	, string_to_lower( Descr, Descr_L )	%	Lowercase to ensure matching
	, sys_string_split( Descr_L, ` `, Descr_Split )	%	Transform to a list to allow easier searching
	
	, ( sys_append( _, [ New_Qty, `pcs` | _ ], Descr_Split ),	%	Backward use of append to search through list
		q_regexp_match( `^\\d+$`, New_Qty, _ )	%	Double check the quantity is actually a number
	
		;	sys_append( _, [ `per`, Multiplier | _ ], Descr_Split ),
			q_regexp_match( `^\\d+$`, Multiplier, _ ),
			sys_calculate_str_multiply( Multiplier, Quantity, New_Qty )		
	)
	
	, sys_retract( result( _, LID, line_quantity, Quantity ) )	%	Remove existing quantity
	, assertz_derived_data( LID, line_quantity, New_Qty, i_modified_quantity_from_description )	%	Insert new quantity

	, !
.