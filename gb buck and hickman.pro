%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GB BUCK and HICKMAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( gb_buck_and_hickman, `11 June 2015` ).

i_date_format( _ ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, [ q0n(line), generic_horizontal_details( [ [ `Purchase`, `Order`, `No`, `:` ], delivery_location, w, `/` ] ) ]

	, [ q0n(line), generic_horizontal_details( [ [ `Purchase`, `Order`, `No`, `:` ], order_number, s1, newline ] ) ]
	
	, [ q0n(line), generic_horizontal_details( [ [ `Account`, tab, `Our`, `Operator` ] ] ), generic_horizontal_details( [ [ at_start, dummy(s1), tab ], buyer_contact, s1 ] ) ]

	, [ q0n(line), generic_horizontal_details( [ [ `Account`, tab, `Our`, `Operator` ] ] ), generic_horizontal_details( [ [ at_start, dummy1(s1), tab, dummy2(s1), tab ], invoice_date, date ] ) ]

	, [ q0n(line), generic_horizontal_details( [ [ `Deliver`, `To`, `:` ] ] ), q0n(line), buyer_ddi_line ]
	
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

	  or( [
		[ test( test_flag ), buyer_registration_number( `GB-ADAPTRI` ) ]

		, buyer_registration_number( `GB-BUCKHIC` )
		
	] )

	, suppliers_code_for_buyer( `12214655` )

	, agent_code_3(`4400`)

	, delivery_party( `BUCK & HICKMAN` ) 

	, or( [ check( q_sys_sub_string( FROM_EMAIL, _, _, `@hilti.com` ) ), buyer_email( FROM_EMAIL ) ] )
	
	, sender_name( `Buck & Hickman (Brammer UK Ltd.)` )
	
] )

:-
	i_mail( from, FROM_EMAIL )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( buyer_ddi_line, [
%=======================================================================

	  q0n( anything )
	
	, `Tel`
	
	, `:`
	
	, buyer_ddi(s1)
	
	, q0n( [ tab, append( buyer_ddi(s1), ` `, `` ) ] )
	
	, newline 

	, trace( [ `buyer_ddi (begins with)`, buyer_ddi ] )
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

	, line

	, q0n( or( [ line_invoice_rule, line ] ) )
	
	, line_end_line
	
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Quantity`, tab, `Product`, tab, `Required` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [ `-`, `-`, `-`, `-`, `-`, `-` ] ).
%=======================================================================

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, q01( generic_descr_append )

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
		
		, set( no_item_needed )
	
	] )
	
	, or( [
	
		line_item_line
		
		, test( no_item_needed )
		
	] )

	, count_rule
	
	, clear( no_item_needed )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_no( [ line_quantity, d ] )
	
	, dummy_uom(s1)

	, line_quantity_uom_code( `PAC` )

	, tab

	, generic_item( [ line_descr, s1 ] )

	, q0n( [ tab, append( line_descr(s1), ` `, `` ) ] )

	, tab
	
	, generic_item( [ line_original_order_date, date ] )
	
	, tab

	, generic_no( [ line_unit_amount, d, [ word, tab ] ] )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  a(s1), tab
	
	, or( [
	
		generic_item( [ line_item, [ begin, q(dec,4,10), end ], newline ] )
		
		, generic_item( [ dummy_item, s1, newline ] )
	
	] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )

	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)

	, generic_horizontal_details( [ [ `Total`, `Value`, `:` ], total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [
	
		[ with( invoice, delivery_charge, Charge )
	
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