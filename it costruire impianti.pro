%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT COSTRUIRE IMPIANTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_costruire_impianti, `17 July 2014` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_date_format( _ ).

i_format_postcode( X, X ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set( reverse_punctuation_in_numbers )
	
	, get_fixed_variables

	, get_delivery_details
	
	, get_shipping_instructions
	
	, get_order_number

	, get_invoice_date

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
	
	sender_name(`Costruire Impianti`)
	
	, buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, or( [ [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	
	    , supplier_registration_number( `P11_100` )                      %PROD
		
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10658906` ) ]	%TEST
	
		, suppliers_code_for_buyer( `15204977` )						%PROD
		
	] )
	
	, delivery_party( `COSTRUIRE IMPIANTI` )
	
	, buyer_dept( `ITCOST15044127` )
	
	, delivery_from_contact( `ITCOST15044127` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q0n(line)
	
	, delivery_start_header
	
	, q01(line)
	
	, delivery_dept_line
	
	, q10( [ test( dept )
	
		, q(0,2,line)
	
		, delivery_street_line
		
		, q01(line)
		
		, delivery_location_line

	] )

] ).

%=======================================================================
i_line_rule( delivery_start_header, [
%=======================================================================

	q0n(anything)
	
	, read_ahead( [ `Consegna`, `Presso` ] )
	
	, delivery_left_margin(s1), newline

] ).

%=======================================================================
i_line_rule( delivery_dept_line, [
%=======================================================================

	nearest( delivery_left_margin(start), 10, 10 )
	
	, or( [ [ `Deposito`, `principale`, delivery_note_number(`15204977`) ]
	
		, [ generic_item( [ delivery_dept, s1 ] ), set( dept ) ]
		
	] )

	, newline
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [
%=======================================================================

	nearest( delivery_left_margin(start), 10, 10 )
	
	, generic_item( [ delivery_street, s1, newline ] )

] ).

%=======================================================================
i_line_rule( delivery_location_line, [
%=======================================================================

	nearest( delivery_left_margin(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, w, tab ] )
	
	, generic_item( [ delivery_state, w, tab ] )
	
	, generic_item( [ delivery_city, s1, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Oggetto`, tab ], shipping_instructions, s1 ] )
	
	, check( shipping_instructions = Ship )
	
	, customer_comments(Ship)
	
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
	
	, generic_vertical_details( [ [ `Number`, tab, `Date` ], `Number`, end, order_number, s1, tab ] )
	
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
	
	, generic_vertical_details( [ [ `Number`, tab, `Date` ], `Date`, end, 0, 30, invoice_date, date, tab ] )

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
	
		, or( [ line_invoice_line
	
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`Pos`, `.`, tab, `Articolo`, tab
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Trasporto`, `a`, `Cura`, tab
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	line_order_line_number(d)
	
	, line_item_for_buyer(s1), tab
	
	, check( strip_string2_from_string1( line_item_for_buyer, `HI`, ITEM ) )
	
	, line_item(ITEM)
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, line_quantity_uom_code(s1), tab
	
	, line_quantity(d), tab
	
	, line_unit_amount_x(d), q10( dummy(d) ), tab
	
	, generic_item( [ line_net_amount, d, [ dummy(d), tab ] ] )
	
	, line_original_order_date(date), newline
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line)
	
	, generic_vertical_details( [ [ `Totale`, `ordine`,  newline ], `ordine`, end, 0, 65, total_net, d, newline ] )

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






