%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HOCHTIEF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( pl_hochtief, `14 May 2015` ).

i_date_format( _ ).
i_format_postcode(X,X).

i_pdf_paramater( x_tolerance_100, 100 ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).
i_user_field( invoice, type_of_supply, `Type of Supply` ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

i_op_param( xml_encoding, _, _, _, `utf-16` ).

%=======================================================================
i_page_split_rule_list( [ check_for_new_format ] ):- i_mail( to, `orders.test@ecx.adaptris.com` ).
%=======================================================================
i_section( check_for_new_format, [ check_for_new_format_line ] ).
%=======================================================================
i_line_rule_cut( check_for_new_format_line, [ 
%=======================================================================
	check_text( `ecat-Zamówienie` )
	, set( chain, `pl hochtief 2` )
	, trace( [ `Chaining to NEW FORMAT` ] ), set( re_extract )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, get_fixed_variables

	, gen_vert_capture( [ [ `Numer`, `zamówienia`, tab ], order_number, s1, tab ] )
	, gen_vert_capture( [ [ `Data`, newline ], invoice_date, date, newline ] )

	, get_delivery_address

	, get_totals
	
	, get_invoice_lines
	
] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  gen_capture( [ [ `Osoba`, `kontaktowa`, `autor`, `wniosku`, tab ], buyer_contact, s1, newline ] ) 
	, gen_capture( [ [ `Telefon`, tab ], buyer_ddix, s1, [ check( strip_string2_from_string1( buyer_ddix, `/`, DDI ) ), buyer_ddi( DDI ) ] ] )
	, gen_capture( [ [ `E`, `-`, `mail`, tab ], buyer_email, s1, newline ] )
	, gen_capture( [ [ `Data`, `dostawy`, `:`, tab ], delivery_date, date, newline ] )
	
	, get_delivery_details
	
] ):- not( grammar_set( do_not_process ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

%%%%%%%%%%%%%%%%%%
	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `PL-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`3100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
%%%%%%%%%%%%%%%%%%
	
	, sender_name( `Hochtief` )
	
	, suppliers_code_for_buyer( `15702430` )
	
	, set( no_pc_cleanup )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY INFO	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q0n(line)
	
	, trace([`here`])

	, generic_line( [ [ q0n(anything), read_ahead( [ `Dane`, `odbiorcy`, `:` ] ), deliv_hook(s1), tab ] ] )
	
	, trace([`here1`])
	
	, generic_line( [ [ nearest_word(deliv_hook(start),10,10), delivery_contact(s1), trace([delivery_contact]) ] ] )
	
	, generic_line( [ [ nearest_word(deliv_hook(start),10,10), `Telefon`, `:`
	
		, delivery_ddix(s1), [ check( strip_string2_from_string1( delivery_ddix, `/`, DDI ) ), delivery_ddi( DDI ) ] 
		
	] ] )
	
	, generic_line( [ [ nearest_word(deliv_hook(start),10,10), `E`, `-`, `mail`, `:`, q10(delivery_email(s1)), tab ] ] )

] ).

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	q0n(line)
	
	, trace([`here`])

	, generic_line( [ [ q0n(anything), read_ahead( [ `Odbierający`, `zamówienie`, `:` ] ), deliv_2_hook(s1), tab ] ] )
	
	, trace([`here1`])
	
	, generic_line( [ [ nearest_word(deliv_2_hook(start),10,10), delivery_party(s1), trace([delivery_party]) ] ] )
	
	, or( [
	
		[ generic_line( [ [ nearest_word(deliv_2_hook(start),10,10), delivery_dept(s1), trace([delivery_dept]) ] ] ) ]
		
		, line
		
	] )
	
	, or( [
	
		[ generic_line( [ [ nearest_word(deliv_2_hook(start),10,10), delivery_address_line(s1), trace([delivery_address_line]) ] ] ) ]
		
		, line
		
	] )
	
	, generic_line( [ [ nearest_word(deliv_2_hook(start),10,10), delivery_street(s1), trace([delivery_street]) ] ] )
	
	, generic_line( [ [ nearest_word(deliv_2_hook(start),10,10), delivery_postcode(f( [ begin, q(dec,2,2), q(other("-"),1,1), q(dec,3,3), end ] ) ), delivery_city(s1), trace([delivery_postcode]), trace([delivery_city]) ] ] )
	
	, generic_line( [ [ nearest_word(deliv_2_hook(start),10,10), `Polska` ] ] )
	
	, or( [ line_header_line
	
		, [ trace( [ `Special Rule Triggered - document NOT processed` ] )
			, delivery_note_reference( `special_rule` )
			, set( do_not_process )
		]
	] )

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
	
	, set(regexp_cross_word_boundaries)
	
	, generic_horizontal_details( [ [ `Razem`, `:` ], total_net, d, [ `PLN`, newline ] ] )

	, clear(regexp_cross_word_boundaries)
	
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line
	  
	, trace([`here`])

	, q0n( or( [ line_invoice_rule, line ] ) )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`LP`, tab, `Ilość`, tab, `Numer`, `artykułu`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	or( [ 
	
		[ `Razem`, `:` ]

		, [	`LP`, tab, `Ilość`, tab, `Numer`, `artykułu` ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_invoice_line
  
	, generic_line( [ [ `Opis`, `:`, tab, line_descr(s1), newline ] ] )
	
	, trace([line_descr])
	
	, line
	
	, generic_line( [ [ `Data`, `dostawy`, `:`, tab, line_original_order_date(date), newline ] ] )
	
	, trace([line_original_order_date])
	
	, generic_line( [ [ `Dekretacja`, `:`, tab, or( [ `Projekt`, `MPK` ] ), `:`, append(line_descr(s1), `~Projekt: `, ``), newline ] ] )
	
	, trace([`here2`])
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_no( [ line_order_line_number, d, tab ] )
	
	, generic_no( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, or( [
	
		[ line_item( f( [ begin, q(dec,4,10), end ] ) ) ]
		
		, [ line_item(`Missing`) ]
		
	] ), tab
	
	, generic_item( [ line_dummy, s1, tab ] )

	, set(regexp_cross_word_boundaries)
	
	, generic_item( [ line_unit_amount, d, [ `PLN`, tab ] ] )
	
	, generic_item( [ line_net_amount, d, [ `PLN`, newline ] ] )
	
	, clear(regexp_cross_word_boundaries)

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