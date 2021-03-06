%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - WESTERN POWER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( western_power, `18 September 2014` ).

i_date_format( _ ).

i_pdf_parameter(dont_tokenise_on_font_change, 1).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(postcode_format_relax_same_font_requirement_on_second_word)
	
	, get_fixed_variables

	, get_delivery_address
	
	, get_order_number
	
	, get_delivery_block

	, get_invoice_date

	, get_buyer_contact
	
	, get_buyer_email
	
	, get_delivery_date

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

	, buyer_registration_number( `GB-WESTERN` )

	, or( [ [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	
	    , supplier_registration_number( `P11_100` )                      %PROD
		
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

%	, suppliers_code_for_buyer( `12292732` )
	
%	, delivery_party( `WESTERN POWER DISTRIBUTION` )
	
	, buyer_ddi(`0845 601 2989`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	q0n(line)
	
	, delivery_address_header
	
	, line, line
	
	, delivery_street_line_1
	
	, up, up, up
	
	, delivery_street_line_2
	
	, line, line
	
	, q10(line)
	
	, delivery_city_line
	
	, delivery_state_line
	
	, delivery_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_address_header, [
%=======================================================================

	`Deliver`, `To`, `:`

] ).

%=======================================================================
i_line_rule( delivery_street_line_1, [
%=======================================================================

	generic_item( [ delivery_street, s1, gen_eof ] )

] ).

%=======================================================================
i_line_rule( delivery_street_line_2, [
%=======================================================================

	generic_item( [ delivery_street, s1, gen_eof ] )

] ).

%=======================================================================
i_line_rule( delivery_city_line, [
%=======================================================================

	generic_item( [ delivery_city, s1, gen_eof ] )

] ).

%=======================================================================
i_line_rule( delivery_state_line, [
%=======================================================================

	generic_item( [ delivery_state_x, s1, gen_eof ] )

] ).

%=======================================================================
i_line_rule( delivery_postcode_line, [
%=======================================================================

	generic_item( [ delivery_postcode, pc, gen_eof ] )
	
	, check( delivery_postcode = PC )
	
	, check( strip_string2_from_string1( PC, ` `, PC_Strip ) )
	
	, check( strcat_list( [ `GBWPD`, PC_Strip ], BCFB ) )
	
	, buyers_code_for_buyer( BCFB )

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
	
	, generic_horizontal_details( [ [ `Order`, `Number`, `:` ], order_number, s1, gen_eof ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY BLOCK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_block, [
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ [ `Revision`, `:`, peek_fails( [ `0`, gen_eof ] ) ], 25, invoice_type_x, s1, gen_eof ] )
	
	, invoice_type( `ZE` )

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
	
	, generic_horizontal_details( [ [ `Date`, `:` ], invoice_date, date, gen_eof ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	buyer_email( From )
	
	, buyer_contact( Contact )

] )

:-

	i_mail( from, From )
	, sys_string_split( From, `@`, [ Name | _ ] )
	, sys_string_split( Name, `.`, [ First, Last ] )
	, strcat_list( [ First, ` `, Last ], Contact )
.

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

	`No`, `.`, tab, `and`, `Description`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`*`, `*`, `*`, `*`
	
] ).

%=======================================================================
i_rule( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
	, q10(line_uom_line)
	
	, line_descr_line
	
	, qn0( [ peek_fails(line_end_line)
	
		, line_descr_append
		
	] )
	
	, clear( line_item_found )
	
	, check( line_descr = Text )
	
	, q10( [ check( i_user_check( check_for_delivery, Text ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
		
		, trace( [ `delivery`, delivery_charge ] )
	
	] )
	
	, or( [ [ check( i_user_check( check_uom, Text ) )

			, line_quantity_uom_code(`PAC`)
			
		]
		
		, [ check( dummy_uom_code = Code )
		
			, line_quantity_uom_code(Code)
			
		]
	
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item( [ line_order_line_number, w, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, q10( generic_item( [ line_quantity, d ] ) )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_uom_line, [
%=======================================================================

	generic_item( [ dummy_uom_code, s1, newline ] )
	
	, check( dummy_uom_code(start) > 0 )
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	q10( read_ahead( [ q0n(anything), line_item( f( [ begin, q(dec,6,10), end ] ) ), set( line_item_found ) ] ) )
	
	, append( line_descr(s1), ` `, `` ), newline
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_append, [
%=======================================================================

	peek_fails( [ `DELIVERY`, `FOR`, `THE`, `ATTENTION` ] )
	
	, q10( [ peek_fails( test( line_item_found ) )
	
		, read_ahead( [ q0n(anything), line_item( f( [ begin, q(dec,6,10), end ] ) ), set( line_item_found ) ] )
		
	] )
	
	, append( line_descr(s1), ` `, `` ), newline
	
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
	
	, generic_horizontal_details( [ [ `Total`, `Order`, `Value`, `£`, tab ], total_net, d, newline ] )

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
i_user_check( check_uom, UOM ):-
%=======================================================================

	  string_to_lower( UOM, UOM_L )
	, sys_string_split( UOM_L, ` `, UOM_Words )
	, q_sys_member( UOM_Word, UOM_Words )
	, q_sys_member( UOM_Word, [ `packs` ] )
	, trace( `UOM Code: PAC` )
.



