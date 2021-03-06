%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CARRIER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( carrier, `31 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_buyer_contact
	
	, get_buyer_email
	
	, get_delivery_details

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals
	
	, set( no_pc_cleanup )

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

	, buyer_registration_number( `NL-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Carrier Refrigeration Benelux B.V.` )
	, set( reverse_punctuation_in_numbers )
	
	, or( [ [ test( test_flag )
			, suppliers_code_for_buyer( `17965070` )
		]
		
		, suppliers_code_for_buyer( `17965070` )
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q(0,15,line)

	, generic_vertical_details( [ [ `Referentie`, `/`, `Orderdatum` ], order_number, sf, [ `van`, invoice_date(date) ] ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	q(0,15,line)
	
	, generic_vertical_details( [ `Contactpersoon`, buyer_contact_x, s1, newline ] )
	
	, check( sys_string_split( buyer_contact_x, ` `, [ Forename | SurnameList ] ) )
	, check( wordcat( SurnameList, Surname ) )
	
	, check( q_sys_sub_string( Forename, 1, 1, Initial ) )
	, check( strcat_list( [ Initial, `. `, Surname ], Con ) )
	, buyer_contact( Con )
	, trace( [ `Buyer contact`, buyer_contact ] )
	
] ).

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	q(0,15,line)
	
	, generic_vertical_details( [ `Email`, buyer_email, s1, newline ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	q(0,25,line)
	
	, generic_vertical_details( [ `Afleveradres`, delivery_party, s1 ] )
	
	, generic_horizontal_details( [ nearest( delivery_party(start), 10, 10 ), delivery_street, s1 ] )
	
	, delivery_postcode_and_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	nearest( delivery_party(start), 10, 10  )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,4), end ] ] )
	
	, append( delivery_postcode( f( [ begin, q(alpha,2,2), end ] ) ), ` `, `` )
	
	, trace( [ `Full Postal Code`, delivery_postcode ] )
	
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

	  qn0(line)
	  
	, generic_horizontal_details( [ [ `Totale`, `orderwaarde`, q0n(anything), `EUR` ], total_net, d ] )

	, check( total_net = Net )
	, total_invoice( Net )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `artikel`, tab, `afleverdatum`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ `Pagina`

		, [ `Aub`, `ons` ]
		
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  generic_line( [ [ generic_item( [ line_order_line_number, d, q10( tab ) ] ), generic_item( [ line_descr, s1, newline ] ) ] ] )
	  
	, line_invoice_line
	
	, line_item_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item( [ line_item_for_buyer, w, tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	, q10( [ without( delivery_date )
		, check( line_original_order_date = Date )
		, delivery_date( Date )
	] )

	, generic_item_cut( [ line_quantity, d ] )

	, generic_item_cut( [ line_quantity_uom_code, w, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )

	, generic_item_cut( [ uom, s1, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	qn1( 
		or( [ `Uw`
			, `artikelnummer`
		] )
	)
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

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