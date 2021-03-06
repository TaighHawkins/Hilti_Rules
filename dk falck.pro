%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DK FALCK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( dk_falck, `30 December 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_capture( [ [ `Ordrenr`, `.` ], 200, order_number, s1 ] )
	, get_invoice_date

	, get_delivery_details
	
	, gen_capture( [ [ gen_beof, `Indkøber` ], 200, buyer_contact, s1, newline ] )
	, gen_capture( [ [ gen_beof, `Indkøber` ], 200, delivery_contact, s1, newline ] )
	
	, gen_capture( [ [ `Telefon`, tab, `Tlf`, `.` ], buyer_ddi, s1, newline ] )
	, gen_capture( [ [ `Telefon`, tab, `Tlf`, `.` ], delivery_ddi, s1, newline ] )
	
	, gen_capture( [ [ `I`, `alt`, `DKK`, `ekskl`, `.`, `moms` ], total_net, d, newline ] )
	, gen_capture( [ [ `I`, `alt`, `DKK`, `ekskl`, `.`, `moms` ], total_invoice, d, newline ] )
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, gen_section( [ line_invoice_line, generic_descr_append ] )
	
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
	    , suppliers_code_for_buyer( `11296615` )                      %PROD
	])

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, set( reverse_punctuation_in_numbers )
	
	, sender_name(`Falck A/S`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  q0n(line)
	
	, generic_horizontal_details( [ `Bilagsdato`, 200, invoice_date_x, s1, newline ] )
	
	, check( strip_string2_from_string1( invoice_date_x, `.`, Date ) )
	
	, invoice_date(Date)
	
	, trace( [ `got invoice date`, invoice_date ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,3,line)
	
	, generic_horizontal_details( [ read_ahead(`Falck`), delivery_party, s1, newline ] )
	
	, line
	
	, delivery_street_line(1,0,500)
	
	, q10(line)
	
	, delivery_postcode_city_line(1,0,500)
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	  generic_item( [ delivery_street, s1, newline ] )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ delivery_city, s1, newline ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GEN SECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`Nummer`, tab, `Beskrivelse`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`I`, `alt`, `DKK`, `ekskl`
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item( [ line_item_for_buyer, w, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_item, s1, tab ] )
	
	, line_quantity(d), tab
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, line_unit_amount(d), tab
	
	, q10( generic_item( [ line_original_order_date, date, tab ] ) )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, count_rule

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

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )

	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).