%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT GARBUIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_garbuio, `27 May 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_contacts

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

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
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `13013289` )                      %PROD
	]) ]

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
	  
	  q(0,20,line), generic_horizontal_details( [ [ `ORDINE`, `FORNITORE` ], 200, order_number, s1, newline ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `DATA` ], 300, invoice_date, date, newline ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( buyer_email_line, [ generic_item( [ buyer_email, s1, newline ] ) ] ).
%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q0n(line), generic_vertical_details( [ [ `NS`, `.`, `contatto` ], `Ns`, start, buyer_contact_x, s1, newline ] )
	  
	, check( buyer_contact_x = ConX )
	, check( sys_string_split( ConX, ` `, RevList ) )
	, check( sys_reverse( RevList, NormList ) )
	, check( wordcat( NormList, Con ) )
	, buyer_contact( Con )
	, delivery_contact( Con )
	
	, buyer_email_line( 1, 0, 400 )
	
	, check( buyer_email = Email )
	
	, delivery_email( Email )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(0,5,line), delivery_header_line

	, delivery_thing( [ delivery_party ] )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_city_state_line
	
] ).

%=======================================================================
i_line_rule( delivery_header_line, [ q0n(anything), read_ahead( `Indirizzo` ), delivery_hook(w), `di`, `consegna` ] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [
%=======================================================================

	  nearest( delivery_hook(start), 10, 10 )
	  
	, Read_Variable
	
	, newline
	
	, trace( [ String, Variable ] )

] ):-

	  Read_Variable =.. [ Variable, s1 ]
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_line_rule( delivery_postcode_city_state_line, [
%=======================================================================

	  nearest( delivery_hook(start), 10, 10 )
	  
	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
	
	, delivery_city(sf), `(`
	
	, delivery_state( f( [ begin, q(alpha,2,2), end ] ) ), `)`
	
	, trace( [ `delivery stuffs`, delivery_city, delivery_state, delivery_postcode ] )

] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ qn0(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	 q0n(anything), `TOTALE`, `FORNITURA`, tab, `EUR`, tab
	 
	, read_ahead( [ total_net(d) ] )
	
	, total_invoice(d), newline
	
	, trace( [ `total invoice`, total_invoice ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Riga`, tab, `Ns`, `.` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	  or( [ [ `Interstatario` ]
	  
		, [ `GARBUIO`, `SPA` ]
		
		, [ `Total`, `merce` ]
	
	] )
	  
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
	, or( [ [ q(0,3,line_continuation_line), line_item_line ]
	
		, [ q(3,0,line_continuation_line) ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, q( 0,2,[ append( line_descr(s1), ` `, `` ), tab ] )
	
	, generic_item( [ line_quantity_uom_code, w ] )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, generic_item_cut( [ line_discount_x, d, q10( tab ) ] )
	
	, generic_item_cut( [ line_discount_y, d, tab ] )
	
	, generic_item_cut( [ line_net_amount, d ] )
	
	, generic_item( [ line_original_order_date, date, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	  peek_fails( or( [ `Cod`, `Codice` ] ) )
	  
	, read_ahead( dummy(s1) )
	  
	, check( dummy(start) > line_item_for_buyer(end) )
	
	, check( dummy(end) < line_quantity_uom_code(start) )
	
	, append( line_descr(s1), ` `, `` )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  or( [ [ xor( [ line_item_anchor
	  
				, [ peek_ahead( [ q1n(word), line_item_anchor ] )
					, append( line_descr(sf), ` `, `` ), line_item_anchor
				]
			] )
			
			, generic_item( [ line_item_x, [ begin, q(dec,4,10), end ] ] )
		]
		
		, generic_item( [ line_item_x, [ begin, q(dec,4,10), end ], newline ] )
	] )

] ).

%=======================================================================
i_rule_cut( line_item_anchor, [
%=======================================================================

	qn1(
		or( [ `Cod`
			, `Codice`
			, `Art`
			, `Artikel`
			, `.`
		] )
	)
	
] ).