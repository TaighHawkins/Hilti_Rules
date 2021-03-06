%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - EXPANDED STRUCTURES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( expanded_Structures, `27 February 2015` ).

i_date_format( _ ).

i_pdf_parameter(dont_tokenise_on_font_change, 1).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, date_delivery, `Delivery Date` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, get_delivery_location

	, get_buyer_contact
	
	, get_delivery_contact
	
	, get_order_number

	, get_invoice_date
	
	, get_delivery_date
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `GB-EXPSTRU` )

	, or( [ [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	
	    , supplier_registration_number( `P11_100` )                      %PROD
		
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, suppliers_code_for_buyer( `12479278` )
	
	, delivery_ddi( `01322 296 200` )
	
	, delivery_party( `EXPANDED STRUCTURES` )
	, sender_name( `Expanded Structures Ltd.` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `JOB`, `No`, `:`, tab ], delivery_location, s1, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `BUYER`, `NAME`, `:` ], buyer_contact, s1, gen_eof ] )
	
	, q10( [ q10(line)
	
		, generic_horizontal_details( [ [ `BUYER`, `TEL`, `:` ], buyer_ddi, s1, gen_eof ] )
		
	] )
	
	, q(0,4,line)
	
	, generic_horizontal_details( [ [ `BUYER`, `EMAIL`, `:` ], buyer_email, s1, gen_eof ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,15,line)
	
	, generic_horizontal_details( [ [ `ORDER`, `No`, `:`, tab ], order_number, s1, newline ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ [ `ORDER`, `DATE`, `:`, tab ], invoice_date, date, gen_eof ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_date, [
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ [ `DELIVERY`, `DATE`, `:`, tab ], date_delivery, date, gen_eof ] )

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

	, qn0( [ peek_fails(line_end_line)
	
		, or( [ line_invoice_rule
	
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`ORDERED`, tab, `Exc`, `VAT`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Contact`, `:` ]
	
		, [ `All`, `values`, `in` ]
		
	] )
	
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
		
		, trace( [ `delivery`, delivery_charge ] )
	
	] )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	dummy(s1), tab
	
	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, or( [ read_ahead( [ q0n(word), generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) ] ) 
	
		, line_item(`missing`)
		
	] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, dummy(d), tab
	
	, dummy(s1), tab
	
	, q10( [ dummy(d), tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, with( invoice, date_delivery, Date )
	
	, line_original_order_date(Date)
	
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
	
	, generic_horizontal_details( [ [ `Total`, `Order`, `Value`, tab ], total_net, d, newline ] )

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



