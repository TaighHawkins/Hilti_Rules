%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - WALZ GEBAUDETECHNIK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( walz_gebäudetechnik, `30 January 2015` ).

i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, gen_capture( [ [ at_start, `Bestellung` ], order_number, w, gen_eof ] )
	, gen_capture( [ [ at_start, `Bestellung`, word ], 800, invoice_date, date, newline ] )
	
	, get_delivery_details
	
	, get_buyer_and_delivery_contact_and_email
	, get_buyer_and_delivery_ddi
	
	, get_customer_comments
	, get_shipping_instrucstions
	
	, get_invoice_lines
	
	, gen_capture( [ [ `Gesamtpreis`, `netto` ], total_net, d, `€` ] )
	, gen_capture( [ [ `Gesamtpreis`, `netto` ], total_invoice, d, `€` ] )

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]
	
	, suppliers_code_for_buyer( `10179089` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Walz Gebäudetechnik GmbH` )

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
	
	, generic_horizontal_details( [ read_ahead( [ `Lieferadresse`, `:` ] ), delivery_left_margin, s1 ] )
	
	, delivery_thing( [ delivery_party, s1 ] )
	
	, delivery_thing( [ delivery_street, s1 ] )
	
	, delivery_postcode_and_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_thing( [ Variable, Type ] ), [
%=======================================================================	  

	nearest( delivery_left_margin(start), 10, 10 )
	
	, generic_item( [ Variable, Type ] )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================	  

	nearest( delivery_left_margin(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY CONTACT AND EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_contact_and_email, [
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ [ `eMail`, `Sachbearb`, `.`, `:` ], buyer_email, s1, newline ] )
	
	, check( buyer_email = Email ), delivery_email(Email)
	
	, check( sys_string_split( Email, `@`, [ Name | _ ] ) )
	, check( string_string_replace( Name, `.`, ` `, Contact ) )
	
	, buyer_contact(Contact)
	, delivery_contact(Contact)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY DDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_ddi, [
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ [ `Telefon`, `Sachbearb`, `.`, `:` ], ddi, s1 ] )
	
	, check( i_user_check( clean_up_ddi, ddi, DDI ) )
	
	, buyer_ddi(DDI)
	, delivery_ddi(DDI)

] ).

%=======================================================================
i_user_check( clean_up_ddi, DDI1, DDI )
%=======================================================================
:-
	strip_string2_from_string1( DDI1, ` `, DDI2 ),
	q_sys_sub_string( DDI2, 1, 4, DDI0049 ),
	DDI0049 = `0049`,
	q_sys_sub_string( DDI2, 5, _, DDI3 ),
	strcat_list( [ `0`, DDI3 ], DDI ),
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER DELIVERY FAX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_delivery_fax, [
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ `Fax`, 250, fax, s1 ] )
	
	, check( strip_string2_from_string1( fax, ` /-`, Fax ) )
	
	, buyer_fax(Fax)
	, delivery_fax(Fax)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================

	q(0,9,line)
	
	, generic_line( [ [ `Bestellung`, word, tab, a(date) ] ] )
	
	, generic_horizontal_details( [ at_start, customer_comments, s1, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instrucstions, [
%=======================================================================

	q(0,9,line)
	
	, generic_line( [ [ `Bestellung`, word, tab, a(date) ] ] )
	
	, generic_horizontal_details( [ at_start, shipping_instructions, s1, newline ] )
	
	, generic_horizontal_details( [ read_ahead( [ `Kommission`, `:` ] ), left_margin, s1, newline ] )
	
	, shipping_instructions_line_2

] ).

%=======================================================================
i_line_rule( shipping_instructions_line_2, [
%=======================================================================

	nearest( left_margin(start), 10, 10 )
	
	, append( shipping_instructions(s1), `~`, `` ), newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, trace( [ `found header` ] )

	, qn0( [ peek_fails( line_end_line )

		  , or( [
		
			  line_invoice_rule

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`lfd`, `.`, `Nr`, tab, `Menge`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`ACHTUNG`, `!`, `PRÜFEN`
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
	, generic_horizontal_details( [ at_start, line_quantity_uom_code, w, tab ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	line_order_line_number(d), tab
	
	, line_quantity(d), tab
	
	, read_ahead( line_item_for_buyer(s1) )
	
	, q10( [ `HIL`, `*` ] )
	
	, generic_item( [ line_item, s1, tab ] )
	
	, or( [ check( S = s1 ), check( S = sf ) ] )
	
	, generic_item( [ line_descr, S, q10(tab) ] )
	
	, a(d), tab
	
	, line_unit_amount_x(d), tab
	
	, generic_item( [ line_net_amount, d, `€` ] )
	
	, newline

] ).