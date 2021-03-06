%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IMTECH ENGINEERING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( imtech_engineering, `30 January 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

i_page_split_rule_list( [ new_invoice_page_section ] ).
i_section( new_invoice_page_section, [ new_invoice_page_line, new_invoice_page ] ).
i_line_rule_cut( new_invoice_page_line, [ q0n(anything), `Page`, tab, `:`, `1` ] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  check_pdf_orientation
	  
	, get_fixed_variables
	
	, get_suppliers_code_for_buyer

	, get_order_number

	, get_invoice_date
	
	, get_due_date

	, get_buyer_email
	
	, get_buyer_contact
	
	, get_buyer_ddi
	
	, get_delivery_details
	
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

	, or( [ [ test( landscape ), buyer_registration_number( `GB-IMTECHS` ) ]
	
		, [ test( portrait ), buyer_registration_number( `GB-IMTECHN` ) ]
	
		, buyer_registration_number( `GB-ADAPTRI` )
	] )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Imtech Engineering Services London and South Ltd.` )
	, delivery_party( `IMTECH ENGINEERING SERVICES` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PDF ORIENTATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_pdf_orientation, [ q0n(line), line_header_line ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	  or( [ [ test( landscape )
			, or( [ [ q(0,20,line), generic_vertical_details( [ [ `Invoice`, `/`, `Order` ], scfb_check, s1 ] )
					, check( q_sys_sub_string( scfb_check, _, _, `Engineering Services Central` ) )
					, set( central )
					, suppliers_code_for_buyer( `12216625` )
					, remove( buyer_registration_number )
					, buyer_registration_number( `GB-IMTECHC` )
				]
				
				, suppliers_code_for_buyer( `12309149` ) 
			] )
		]
	  
		, [ test( portrait ), suppliers_code_for_buyer( `12286041` ) ]
		
	] )
	
	, trace( [ `SCFB`, suppliers_code_for_buyer ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,35,line), generic_horizontal_details( [ [ `Purchase`, `Order`, `no`, `.`, tab, `:` ], order_number, s1 ] ) 
	
] ):- grammar_set( landscape ).

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,35,line), generic_horizontal_details( [ [ `Purchase`, `Order`, `no`, `.` ], order_number, s1 ] ) 
	  
	, check( sys_string_split( order_number, `/`, [ Num, Loc ] ) )
	, delivery_location( Loc )
	
] ):- grammar_set( portrait ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,35,line), generic_horizontal_details( [ [ `Order`, `Date`, tab, q10( `:` ) ], invoice_date, date ] ) 
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,35,line), generic_horizontal_details( [ [ `Delivery`, `Date`, tab, `:` ], invoice_date, date ] ) 
	  
] ):- grammar_set( landscape ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [ buyer_email( `order.acknowledgements@imtechnorth.co.uk` ) ] ):- grammar_set( portrait ).
%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	buyer_email( From )

] )
:-
	grammar_set( landscape ),
	i_mail( from, From ),
	not( q_sys_sub_string( From, _, _, `@hilti.com` ) )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,35,line), generic_horizontal_details( [ [ `Project`, `No`, `.`, tab, `:` ], delivery_location_x, s1 ] ) 
	  
	, or( [ [ test( central ), check( delivery_location_x = LocX )
			, check( sys_string_length( LocX, Len ) )
			, check( sys_calculate( Start, Len - 4 ) )
		]
		
		, check( q_sys_sub_string( delivery_location_x, Start, _, `S` ) )
	] )
	
	, check( q_sys_sub_string( delivery_location_x, Start, _, Loc ) )
	
	, delivery_location( Loc )
	, trace( [ `Delivery Location`, delivery_location ] )
	
] ):- grammar_set( landscape ).

%	Disabled due to introduction of delivery_location capture - will remove in April
%=======================================================================
ii_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,35,line), generic_horizontal_details_cut( [ [ `Delivery`, `Address` ] ] )
	  
	, line
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )

	, or( [ [ line
	
			, peek_ahead( generic_line( [ [ q0n(anything), `,`, q0n(anything), `,` ] ] ) )			
			, peek_ahead( gen_count_lines( [ postcode_line( 1, -50, 500 ), CountLessOne ] ) )		
			, check( sys_calculate( Count, CountLessOne + 1 ) )
			
			, delivery_address_in_a_line( Count, -50, 500 )
			
		]
	
		, [ q(3,1,line)
	
			, generic_horizontal_details_cut( [ nearest( generic_hook(start), 10, 10 ), street_2, s1 ] )
			
			, generic_horizontal_details_cut( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1 ] )

			, line
			
			, generic_horizontal_details_cut( [ nearest( generic_hook(start), 10, 10 ), delivery_city, s1 ] )
			
			, generic_horizontal_details_cut( [ nearest( generic_hook(start), 10, 10 ), delivery_postcode, pc ] )
			
		]
		
	] )

	, check( street_2 = Street )
	, delivery_street( Street )
	
] ):- grammar_set( portrait ).

%=======================================================================
i_line_rule_cut( postcode_line, [ q0n(anything), some(pc) ] ).
%=======================================================================
i_line_rule_cut( delivery_address_in_a_line, [
%=======================================================================

	q( 2, 2, [ some(sf), `,` ] )
	
	, generic_item( [ street_2, sf, `,` ] )
	, generic_item( [ delivery_street, sf, `,` ] )
	, generic_item( [ delivery_city, sf, `,` ] )
	, generic_item( [ delivery_postcode, pc ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,35,line), generic_horizontal_details( [ [ `Site`, `Contact`, tab, `:` ], delivery_contact, s1 ] ) 
	
] ):- grammar_set( landscape ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,35,line), generic_horizontal_details( [ [ tab, `Buyer`, tab ], buyer_contact, s1 ] ) 
	
] ):- grammar_set( landscape ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	buyer_contact( Con )
	, trace( [ `Buyer Contact from Email`, Con ] )
	
] )
:- 
	i_mail( from, From ),
	sys_string_split( From, `@`, [ Names | _ ] ),
	string_string_replace( Names, `.`, ` `, Con )
.

%=======================================================================
i_rule( get_buyer_ddi, [ buyer_ddi( `01772 471105` ) ] ):- grammar_set( portrait ).
%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,35,line), generic_horizontal_details( [ [ `Buyer`, `Phone`, `no`, `.` ], 300, buyer_ddi, s1 ] ) 
	
] ):- grammar_set( landscape ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)
	  
	, or( [ generic_horizontal_details( [ [ `Order`, `Total`, `GBP` ], 300, total_net, d, newline ] )
	
		, generic_horizontal_details( [ [ `Order`, `Value` ], total_net, d, newline ] )
	] )

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
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 
		
			  line_invoice_rule
			  
			, generic_line( [ [ append( line_descr(s1), ` `, `` ), newline ] ] )

			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Line`, q10( tab ), `Quantity`, header, set( landscape ) ] ):- not( grammar_set( portrait ) ).
%=======================================================================
i_line_rule_cut( line_header_line, [ `No`, tab, `Qty`, tab, header, set( portrait ) ] ):- not( grammar_set( landscape ) ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Order`, `Total` ]
	
		, [ `Order`, `Value` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )

	, q10( [ with( invoice, due_date, Due )
		, line_original_order_date( Due )
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( [ tab, set( no_uom ) ] ) ] )
	
	, or( [ [ test( no_uom ), clear( no_uom ) ]
	
		, [ peek_fails( test( no_uom ) )
			, generic_item( [ line_quantity_uom_code_x, w, tab ] )
		]
	] )
	
	, or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

		, line_item( `Missing` )
		
	] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )
	
	, q10( generic_item( [ line_percent_discount, d, [ `%`, tab ] ] ) )
	
	, generic_item( [ net_rate, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, line_quantity_uom_code( `EA` )
	
] ):- grammar_set( landscape ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_descr, s1, tab ] )
	
	, or( [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )

		, [ line_item( `Missing` ), generic_item( [ dummy_item, s1, tab ] ) ]
		
	] )

	, generic_item_cut( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_percent_discount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, tab ] )
	
	, generic_item( [ line_original_order_date, date, newline ] )

] ):- grammar_set( portrait ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

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