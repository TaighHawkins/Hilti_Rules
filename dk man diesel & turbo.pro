%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DK MAN DIESEL & TURBO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( dk_man_diesel_turbo, `30 December 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_capture( [ [ `Indkøbsordre`, `nr`, `.`, `:` ], order_number, s1, newline ] )
	, gen_vert_capture( [ [ `Dato`, tab, `Version` ], invoice_date, date, tab ] )

	, get_delivery_details
	
	, gen_vert_capture( [ [ `Vor`, `ref`, `.`, newline ], buyer_email, s1, newline ] )
	, gen_vert_capture( [ [ `Vor`, `ref`, `.`, newline ], delivery_email, s1, newline ] )
	
	, gen_capture( [ [ `Total`, tab, `DKK` ], 400, total_net, d, newline ] )
	, gen_capture( [ [ `Total`, tab, `DKK` ], 400, total_invoice, d, newline ] )

	, gen_section( [ line_invoice_rule ] )
	
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

	, buyer_registration_number( `DK-ADAPTRI` )

	, or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	])

	, or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10550149` ) ]    %TEST
	    , suppliers_code_for_buyer( `11301320` )                      %PROD
	])

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, set( reverse_punctuation_in_numbers )
	
	, sender_name(`MAN Diesel & Turbo`)
	
	, delivery_party(`MAN Diesel & Turbo`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_thing( [ Var ] ), [ nearest( generic_hook(start), 10, 10 ), generic_item( [ Var, s1 ] ) ] ).
%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Leveringsadresse`, `:` ] ] )
	
	, line
	
	, generic_horizontal_details( [ at_start, delivery_contact, s1, newline ] )
	, check( delivery_contact = Con )
	, buyer_contact(Con)
	
	, line
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GEN SECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`Pos`, `.`, `nr`, `.`, tab

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [
	
		[ `Total`, tab, `DK` ]
		
		, [ `For`, `all`, `suppliers` ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
	, line_descr_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item( [ line_order_line_number, w, tab ] )
	
	, line_quantity(d)
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, generic_item( [ line_unit_amount, d, `/` ] )
	
	, word, newline

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	or( [
	
		[ generic_item( [ line_descr, s, `#` ] )
	
			, generic_item( [ line_item, w ] )
			
		]
		
		, generic_item( [ line_descr, s1 ] )
		
	] )
	
	, newline

] ).