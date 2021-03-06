%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HOTCHKISS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hotchkiss, `13 January 2015` ).

i_date_format( _ ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_date, `Delivery Date` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, get_delivery_location
	
	, get_buyer_email
	
	, get_buyer_contact
	
	, get_order_number

	, get_invoice_date
	
	, get_delivery_date
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, get_invoice_totals

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

	, buyer_registration_number( `GB-ADAPTRI` )

	, or( [ [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	
	    , supplier_registration_number( `P11_100` )                      %PROD
		
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12224126` )
	
	, delivery_party( `HOTCHKISS LIMITED` )
	
	, sender_name( `Hotchkiss Ltd.` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [
%=======================================================================

	or( [ [ q0n(line)
	
			, generic_horizontal_details( [ [ `Contract`, `No`, `.` ], delivery_location, s1, newline ] )
			
		]
		
		, delivery_note_number( `12224126` )
		
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Our`, `Reference`, `:` ], buyer_contact, s1, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Order`, `No`, `.` ], order_number, s1, newline ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Order`, `Date` ], invoice_date_x, s1, newline ] )
	
	, check( strip_string2_from_string1( invoice_date_x, `.`, Date ) )
	
	, invoice_date(Date)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_date, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Delivery`, `Date` ], delivery_date, date, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line
	
	, qn0( [ peek_fails(line_end_line)
	
		, or( [ line_invoice_rule
		
			, line_defect_line
	
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`No`, `.`, tab, `Description`, tab
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Total`, `£`
	
] ).

%=======================================================================
i_rule( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
	, check( line_descr = Text )
	
	, q10( [ check( i_user_check( check_for_delivery, Text ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_defect_line, [ q0n(anything), tab, num(d), q0n(anything), tab, num(d) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	q10( [ line_item(f( [ begin, q(dec,4,10), end ] ) ), q10(`-`) ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, line_quantity(d), line_quantity_uom_code(w), tab
	
	, or( [ [ line_unit_amount(d), tab
	
			, dummy(d), tab
	
			, generic_item( [ line_net_amount, d, newline ] )
			
		]
		
		, [ dummy(d), newline ]
		
	] )
	
	, q10( [ with( invoice, delivery_date, Date ), line_original_order_date(Date) ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Total`, `£`, q10( [ `Excl`, `.`, `VAT` ] ), tab ], total_net, d, newline ] )

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





%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage` ] )
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