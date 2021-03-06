%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - LIEBHERR-HAUSGERATE LIENZE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( liebherr_hausgerate_lienze, `27 July 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_vert_capture( [ [ `Datum`, tab, or( [ `Lieferant`, `Lieferanten` ] ) ], invoice_date, date, tab ] )
	
	, get_delivery_details
	
	, get_buyer_and_delivery_contact
	, gen_vert_capture( [ [ `Email`, `:`, newline ], buyer_email, s1, newline ] )
	, gen_vert_capture( [ [ `Email`, `:`, newline ], delivery_email, s1, newline ] )
	
	, get_invoice_lines
	
	, gen_vert_capture( [ [ `Summe`, `(`, `Netto`, `)`, newline ], total_net, d, `EUR` ] )
	, gen_vert_capture( [ [ `Summe`, `(`, `Netto`, `)`, newline ], total_invoice, d, `EUR` ] )
	
	, [ without( total_net )
		, gen_vert_capture( [ [ `Waren`, tab, `USt` ], total_net, d, `EUR` ] )
	]
	, [ without( total_invoice )
		, gen_vert_capture( [ [ `Waren`, tab, `USt` ], total_invoice, d, `EUR` ] )
	]
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

	  set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, suppliers_code_for_buyer( `10014658` )
	
	, buyer_dept( `16989201` )
	
	, delivery_from_location( `16989201` )

	, sender_name( `LIEBHERR-Hausgeräte Lienz GmbH` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(0,30,line)
	
	, generic_horizontal_details( [ read_ahead( [ `Lieferanschrift`, newline ] ), delivery_left_margin, s1 ] )
	
	, delivery_thing( [ delivery_party, s1 ] )
	
	, delivery_thing( [ delivery_street, s1 ] )
	
	, delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_thing( [ Varaible, Type ] ), [
%=======================================================================

	  nearest( delivery_left_margin(start), 10, 10 )
	
	, generic_item( [ Varaible, Type ] )

] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [
%=======================================================================

	  nearest( delivery_left_margin(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, [ q(alpha,0,1), q(other("-"),0,1), begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_contact, [
%=======================================================================

	q(0,30,line), generic_vertical_details( [ [ `Sachbearbeiter`, tab, `Datum` ], contact, s1 ] )
	
	, check( i_user_check( reverse_contact, contact, Con ) )
	
	, buyer_contact(Con)
	, delivery_contact(Con)
	
	, trace( [ `got buyer and delivery contact`, Con ] )

] ).

%=======================================================================
i_user_check( reverse_contact, Con1, Con )
%=======================================================================
:-
	sys_string_split( Con1, ` `, [ Surname, First_name ] ),
	strcat_list( [ First_name, ` `, Surname ], Con ),
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ line_invoice_rule

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Benennung`, newline
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `Summe`, `(`, `Netto`
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, generic_horizontal_details( [ at_start, line_descr, s1, newline ] )
	
	, order_number_line
	
	, q10( [ peek_fails( test( got_first_line ) )
	
		, generic_horizontal_details( [ [ at_start, read_ahead( customer_comments(s1) ) ], shipping_instructions, s1, newline ] )
		
		, set( got_first_line )
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item, w, tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, line_quantity(d)
	
	, q10( line_quantity_uom_code(w) ), tab

	, generic_item( [ line_unit_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( order_number_line, [
%=======================================================================

	  or( [
	
		[ with( order_number ), a(wf), `-` ]
		
		, [ generic_item( [ order_number, wf, `-` ] ) ]
		
	] )
	
	, line_order_line_number(d), newline

] ).