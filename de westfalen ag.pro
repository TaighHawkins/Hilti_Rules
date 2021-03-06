%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE WESTFALEN AG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( westfalen_ag, `19 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_order_number

	, get_delivery_details

	, get_contacts

	, get_faxes
	
	, get_ddis

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

	, get_invoice_lines

] ):- not( grammar_set( do_not_process ) ).

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, or( [ 
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, suppliers_code_for_buyer( `10128305` ) 

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line)
	
	, generic_horizontal_details( [ [ at_start, `Bestellung` ], order_number, sf, [ `vom`, generic_item( [ invoice_date, date ] ) ] ] )
	
] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Ihr`, `Ansprechpartner` ], buyer_contact, s1 ] )
	
	, check( buyer_contact = Con )
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_ddis, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Fon` ], buyer_ddi_x, s1 ] )

	, check( string_string_replace( buyer_ddi_x, `+49 (0)`, `0`, DDI_1 ) )
	, check( strip_string2_from_string1( DDI_1, `/`, DDI_2 ) )

	, buyer_ddi( DDI_2 )
	, delivery_ddi( DDI_2 )

] ).

%=======================================================================
i_rule( get_faxes, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Fax` ], buyer_fax_x, s1 ] )

	, check( string_string_replace( buyer_fax_x, `+49 (0)`, `0`, Fax_1 ) )
	, check( strip_string2_from_string1( Fax_1, `-`, Fax_2 ) )
	
	, buyer_fax( Fax_2 )
	, delivery_fax( Fax_2 )
	
	, q10( [ generic_horizontal_details( [ read_ahead( [ q0n(word), `@` ] ), buyer_email, s1 ] )
		, check( buyer_email = Email )
		, delivery_email( Email )
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q0n(line), generic_horizontal_details( [ `Lieferanschrift` ] )	  
	, check( generic_hook(start) = Start )
	
	, qn0( gen_line_nothing_here( [ Start, 10, 10 ] ) )
	
	, q10( generic_line( [ `Firma` ] ) )
	
	, delivery_address_rule( [ Start, delivery_party ] )

	, delivery_address_rule( [ Start, delivery_dept ] )
	
	, delivery_address_rule( [ Start, delivery_street ] )
	
	, delivery_postcode_city_line( [ Start ] )
	
] ).

%=======================================================================
i_rule( delivery_address_rule( [ Start, Var ] ), [
%=======================================================================

	qn0( gen_line_nothing_here( [ Start, 10, 10 ] ) )
	
	, generic_horizontal_details( [ [ nearest( Start, 10, 10 ), peek_fails( `Firma` ) ], Var, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line( [ Start ] ), [
%=======================================================================

	  nearest( Start, 10, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Gesamtnettowert`, `ohne`, `MwSt`, `.`, `in`, `EUR` ], 300, total_net, d, newline ] ) )
	  
	, check( total_net = Net )
	, total_invoice( Net )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `Qualitätsmanagementsystem` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n(

		or( [ 
		
			  line_invoice_rule

			, line

		] )

	), line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Bestellmenge`, `/`, `-`, `einheit` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ q0n(anything), `Gesamtnettowert`, `ohne` ]

	] )
	
] ).


%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line( 1, -410, 500 )

	, line_values_line( 1, -410, 500 )

	, or( [ [ qn0( [ peek_fails( line_end_line ), gen_line_nothing_here( [ -350, 50, 10 ] ) ] )
			, q01(line), line_item_line 	
		]
		
		, line_item( `Missing` ) 
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d ] )

	, or( [ generic_item_cut( [ line_item_for_buyer, s1, tab ] ), tab ] )

	, generic_item_cut( [ line_descr, s, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  generic_item_cut( [ line_quantity, d ] )

	, generic_item_cut( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_unit_amount, d, [ q10( [ `/`, generic_item( [ price_uom, s1 ] ) ] ), tab ] ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  q10( [ dummy(s1), tab ] )
	  
	, qn1( 
		or( [ `Ihre`
			, `Materialnummer`
			, `Artikelnummer`
		] )
	)

	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	
] ).
