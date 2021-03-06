%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FI NCC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fi_ncc, `11 June 2015` ).

i_date_format( _ ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set( reverse_punctuation_in_numbers )

	, get_fixed_variables

	, [ order_number_line, order_date_line ]

	, [ q0n(line), generic_horizontal_details( [ [ `Myyjä`, tab, `Tilaajan`, `yhteyshenkilö`, `työmaalla`,  newline ] ] ), buyer_contact_details_line ]

	, [ q0n(line), generic_horizontal_details( [ [ `Toimitusehto`, tab, `Tilaajan`, `yhteyshenkilö`, `tilausasioissa`,  newline ] ] ), delivery_contact_details_line ]

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

	buyer_registration_number( `FL-ADAPTRI` )

	, shipping_conditions( `S0` )

	, agent_code_3(`3300`)

	, set( no_scfb )
	
	, sender_name( `NCC Rakennus Oy` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( order_number_line, [
%=======================================================================

	`TILAUS`
	
	, tab

	, read_ahead( delivery_location(d) )

	, trace( [ `delivery_location`, delivery_location  ] )

	, read_ahead( wrap( buyers_code_for_buyer(d), `FINCC`, `` ) )

	, order_number(d)

	, q0n(anything) % strange rubbish present here in the PDF

	, `/`

	, append( order_number(s1), `/`, `` )

	, trace( [ `order_number`, order_number ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( order_date_line, [
%=======================================================================

	q0n(anything)

	, invoice_date( date )

	, trace( [ `invoice_date`, invoice_date ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( buyer_contact_details_line, [
%=======================================================================

	q0n( anything )

	, read_ahead( buyer_contact(s1) )

	, check( buyer_contact(start) > 0 )

	, buyer_email(w1)
	
	, append( buyer_email(w1), `.`, `.ncc.fi` )

	, tab

	, buyer_ddi(s1)

	, newline

	, trace( [ `buyer contact, ddi and email`, buyer_contact, buyer_ddi, buyer_email ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_contact_details_line, [
%=======================================================================

	q0n( anything )

	, delivery_contact(s1)

	, check( delivery_contact(start) > 0 )

	, tab

	, delivery_ddi(s1)

	, newline

	, trace( [ `delivery contact and ddi`, delivery_contact, delivery_ddi ] )
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

	, q0n( or( [
	
		line_invoice_rule

		, line
		
	] ) )

	, line_end_line
	
] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Toimitusaika`, tab, `MäärYäksikkö`, tab ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [ `Rivit`, `yhteensä`, `veroton` ] ).
%=======================================================================

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  first_invoice_line
	
	, or( [ item_and_description_line, set( ignore_line ) ] )
	
	, data_line
	
	, q10( [ test( ignore_line )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
	
	, count_rule
	
	, clear( ignore_line )

] ).

%=======================================================================
i_line_rule_cut( first_invoice_line, [
%=======================================================================

	  dummy1(s1)
	
	, tab
	
	, dummy2(s1)
	
] ).

%=======================================================================
i_line_rule_cut( item_and_description_line, [
%=======================================================================

	  line_item(s1)

	, tab

	, line_descr(s1)

	, trace( [ `line_item and line_descr`, line_item, line_descr ] )
] ).

%=======================================================================
i_line_rule_cut( data_line, [
%=======================================================================

	  generic_item( [ line_original_order_date, date ] )
	
	, tab

	, generic_no( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1 ] )

	, tab

	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_no( [ line_net_amount, d ] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )

	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )

	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )

	, line_order_line_number(NEXT_LINE_NUMBER)
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

	, generic_horizontal_details( [ [ `Rivit`, `yhteensä`, `veroton` ], 400, total_net, d, newline ] )

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