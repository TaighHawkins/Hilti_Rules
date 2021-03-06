%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT NORDIMPIANTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_nordimpianti, `26 March 2015` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Rules are also for Caraglio
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_date_format( _ ).
i_format_postcode( X, X ).
i_op_param( xml_transform( delivery_street, In ), _, _, _, Out )
:-
	string_string_replace( In, `,`, ``, Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  nordimpianti_or_caraglio
	
	, get_fixed_variables

	, gen_vert_capture( [ [ `Numero`, `documento` ], `Numero`, end, order_number, s1, newline ] )
	, gen_vert_capture( [ [ `Data`, `documento`, tab, `Numero` ], `documento`, start, invoice_date, date, tab ] )
	
	, get_delivery_address
	
	, gen_capture( [ read_ahead( [ `Commessa`, `:` ] ), customer_comments, s1, newline ] )
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NORDIMPIANTI OR CARAGLIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( nordimpianti_or_caraglio, [
%=======================================================================

	q(0,7,line)
	
	, or( [
	
		[ generic_line( [ `CARAGLIO` ] ), set( caraglio ), trace( [ `CARAGLIO` ] ) ]
		
		, [ generic_line( [ `NORDIMPIANTI` ] ), set( nordimpianti ), trace( [ `NORDIMPIANTI` ] ) ]
		
	] )

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

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `13022540` ) ]    %TEST
	    , suppliers_code_for_buyer( `13022540` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )
	
	, or( [

		[ test( nordimpianti ), sender_name( `Nordimpianti s.r.l.` ) ]
		
		, [ test( caraglio ), sender_name( `Caraglio s.r.l.` ) ]
		
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q(0,50,line)
	
	, generic_horizontal_details( [ [ `Destinazione`, `della`, `merce` ] ] )
	
	, q01(line)
	
	, delivery_thing( [ delivery_party ] )
	
	, q(0,4,line)
	
	, delivery_thing( [ delivery_street ] )
	
	, q(0,3,line)
	
	, delivery_city_state_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_thing( [ Var ] ), [
%=======================================================================

	  nearest( generic_hook(start), 20, 10 )
	
	, generic_item( [ Var, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	  nearest( generic_hook(start), 20, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )

	, generic_item( [ delivery_city, sf, `(` ] )

	, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ], `)` ] )
	
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

	, generic_horizontal_details( [ [ gen_beof, `Totale`, q10(`€`) ], 200, total_net, d, newline ] )

	, check( total_net = Net )
	, total_invoice( Net )

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

	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_line
			
			, processed_delviery_date_line

			, line

		] )

	] )

	, line_end_line 

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Codice`, `merce`, `o`, `servizio`, tab, `Descrizione`, `della`, `merce`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  or( [
	
		[ `IL`, `NUMERO`, `DELL` ]
		
		, [ `Il`, `Fornitore`, `non` ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  or( [
	
		[ test( nordimpianti )
			, generic_item( [ line_item, [ q(alpha("H"),1,1), q(alpha("I"),1,1), q(alpha("L"),1,1), begin, q([alpha,dec],1,8), end ], tab ] )
		]
		
		, [ test( caraglio ), generic_item( [ line_item, w ] ) ]
		
	] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, generic_no( [ rrp, d, [ discount(d), tab ] ] )
	
	, generic_no( [ line_unit_amount, d ] )
	
	, generic_item( [ line_original_order_date, date, newline ] )
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( processed_delviery_date_line, [
%=======================================================================

	  test( caraglio )
	
	, `CONSEGNA`, `TASSATIVA`, `X`, `IL`
	
	, generic_item( [ processed_delviery_date, date, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
] ).