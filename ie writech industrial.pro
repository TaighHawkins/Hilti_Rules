%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - WRITECH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( writech, `28 July 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

i_op_param( xml_transform( Var, In ), _, _, _, Out )
:-
	q_sys_member( Var, [ delivery_party, delivery_street, delivery_city, delivery_state, buyer_contact ] ),
	string_to_upper( In, Out )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_invoice_date
	
	, get_buyer_contact
	
	, get_buyer_ddi
	
	, get_buyer_fax

	, get_buyer_email
	
	, get_delivery_contact
	
	, get_delivery_party
	
	, get_delivery_address
	
	, get_customer_comments
	
	, check_for_proper_header
	
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

	, buyer_registration_number( `IE-WRITECH` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4600`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Writech Industrial Services Ltd.` )
	
	, buyer_ddi( `0449349857` )
	, delivery_ddi( `0449349857` )
	, buyer_fax( `0449349858` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `Order`, `no`, `.` ], order_number, s1 ] ) 
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Date`, `Created` ], invoice_date, date ] ) 
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	buyer_email( From )

] )
:-
	i_mail( from, From ),
	not( q_sys_sub_string( From, _, _, `@hilti.com` ) )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_party, [ 
%=======================================================================

	q(0,15,line), generic_horizontal_details( [ [ `INVOICE`, `TO` ], delivery_party_x, s1 ] )
	
	, check( delivery_party_x = PartyX )
	, check( string_to_upper( PartyX, Party ) )
	, delivery_party( Party )
	
	, or( [ [ check( q_sys_sub_string( Party, _, _, `MANUFACTUR` ) )
			, suppliers_code_for_buyer( `21132302` )
		]
		
		, [ check( q_sys_sub_string( Party, _, _, `INDUSTRIAL` ) )
			, suppliers_code_for_buyer( `14328856` )
		]
	] )

] ).

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Deliver`, `to` ], delivery_hook, s1 ] )
	  
	, or( [ [ check( delivery_hook = `Writech Workshop, Mullingar` )
			, with( invoice, suppliers_code_for_buyer, SCFB )
			, delivery_note_number( SCFB )
			, trace( [ `Workshop rule triggered` ] )
		]
		
		, [ q(2,0,line)
	  
			, check( delivery_hook(start) = Start )	
			, qn0( gen_line_nothing_here( [ Start, 10, 10 ] ) )
			
			, q(2,2, delivery_thing( [ Start, delivery_street, s1 ] ) )

			, delivery_thing( [ Start, delivery_city, s1 ] )
		]
	] )

] ).

%=======================================================================
i_line_rule( delivery_thing_line( [ Start, Var, Par ] ), [ nearest( Start, 10, 10 ), q10( or( [ [ `Co`, `.` ], `Address` ] ) ), generic_item( [ Var, Par ] ) ] ). 
%=======================================================================
i_rule_cut( delivery_thing( [ Start, Var, Par ] ), [ 
%=======================================================================

	  qn0( gen_line_nothing_here( [ Start, 10, 10 ] ) )
	  
	, peek_fails( generic_line( [ [ or( [ [ `Purchase`, `Order` ], `Ireland` ] ) ] ] ) )

	, delivery_thing_line( [ Start, Var, Par ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [
%=======================================================================

	q(0,20,line), generic_horizontal_details( [ [ `Collected`, `by` ], delivery_contact, s1 ] )
	
] ).

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	q(0,20,line), generic_horizontal_details( [ [ `Created`, `by` ], buyer_contact, s1 ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================

	q(0,20,line)
	
	, generic_line( [ [ `Additional`, `Information` ] ] )
	
	, shipping_instructions( `` )
	, customer_comments( `` )
	
	, q0n( generic_line( [ [ read_ahead( append( shipping_instructions(s1), ``, ` ` ) ), append( customer_comments(s1), ``, ` ` ) ] ] ) )
	
	, generic_line( [ [ `Purchase`, `Order` ] ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ `Total`, `Agreed`, `price`, dummy(s1) ], 200, total_net, d, newline ] )

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

			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_rule_cut( check_for_proper_header, [ q0n(line), generic_line( [ [ `Writech`, `No`, `.`, q10( tab ), `Writech` ] ] ), set( proper_header ) ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_header_line, [ `Writech`, `No`, `.`, q10( tab ), `Writech` ] ):- grammar_set( proper_header ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	read_ahead( [
		or( [ [ peek_fails( test( ie ) ), `No`, `Post`, `Code`, set( pc ) ]
			, [ peek_fails( test( pc ) ), `Ireland`, set( ie ) ]
		] ), newline
	] )
	
	, dummy(s1), check( dummy(y) > -180 ), check( dummy(y) < -120 )
	
] ):- not( grammar_set( proper_header ) ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Total`, `Agreed` ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_unit_amount = Net )

		, delivery_charge( Net )
	
	] )
	
	, count_rule
	, line_quantity_uom_code( `EA` )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [ `Item`, `No`, `.`, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item_cut( [ dummy_item, s, [ q10( tab ), check( dummy_item(end) < -345 ) ] ] )
	
	, generic_item_cut( [ line_descr, s, [ q10( tab ), check( line_descr(end) < -125 ) ] ] )
	
	, generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, generic_item( [ dummy_descr, s1, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_net_amount, d, newline ] )

] ).

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
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport` ] )
	, trace( `delivery line, line being ignored` )
.