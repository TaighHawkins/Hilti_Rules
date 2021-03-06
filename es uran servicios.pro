%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - URAN SERVICIOS INTEGRALES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( es_uran_servicios, `15 June 2015` ).

i_date_format( _ ).

i_format_postcode(X,X).

i_pdf_paramater( x_tolerance_100, 100 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, gen_vert_capture( [ [ `Nº`, `de`, `Orden`, `de`, `Compra` ], `Nº`, q(0,0), (start, 0,30), order_number, s1, newline ] )
	, gen_capture( [ [ `Fecha`, `de`, `Pedido` ], invoice_date, date, newline ] )
	
	, get_special_rule
	
	, get_contact_details
	
	, get_delivery_location
	
	, set(reverse_punctuation_in_numbers)
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_invoice_lines

	, gen_capture( [ [ `SUBTOTAL`, `:`, tab ], total_net, d, newline ] )
	, gen_capture( [ [ `SUBTOTAL`, `:`, tab ], total_invoice, d, newline ] )
	
	, clear(reverse_punctuation_in_numbers)
	
] ).

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

	, buyer_registration_number( `ES-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10558391` ) ]    %TEST
	    , suppliers_code_for_buyer( `13603457` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
%%%%%%%%%%%%%%%%%%
	
	, sender_name( `Uran Servicios Integrales` )
	
	, set( no_pc_cleanup )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT UPPER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_special_rule, [ 
%=======================================================================

	q0n(line)
	
	, generic_vertical_details( [ [ `COD`, `.`, `POSTAL` ], postcodex, s1, tab ] )
	
	, or( [ 
	
		[ check( postcodex=`28914` ), trace( [ `Postcode is OK! Processing Document!` ] ) ]
		
		, [ delivery_note_reference( `special_rule` ), trace( [ `Postcode Incorrect! Setting Special Rule!` ] ) ]
		
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPECIAL RULE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_details, [ 
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Pedido`, `por`, `:` ], buyer_contactx, s1, newline ] )

	, check( string_to_upper( buyer_contactx, Buyer ) )
	, buyer_contact( Buyer )
	, delivery_contact( Buyer )
	
	, trace( [ `Buyer Contact`, buyer_contact ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	q0n(line)

	, delivery_header_line
	
	, trace( [ `Here` ] )
	
	, q(0,2,line)
	
	, delivery_dept_line
	
	, trace( [ `Here1` ] )
	
	, q(0,2,line)
	
	, delivery_street_line
	
	, trace( [ `Here2` ] )
	
	, q(0,2,line)
	
	, delivery_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	q0n(anything), read_ahead( [ `Dirección`, `entrega`, `:` ] ), header(w)
	
] ).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ delivery_party, s1 ] ), newline
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), delivery_street(s1)
	
] ).


%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, delivery_city(sf)
	
	, q10( [ `(`, a(sf), `)` ] )
	
	, trace( [ `Delivery City`, delivery_city ] )
	
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

		, or( [ 
		
			get_line_invoice

			, line_continuation_line , line
			])

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`REF`, `.`, tab, `DESCRIPCIÓN`, `DEL`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	`Dirección`, `entrega`, `:`
	
] ).

%=======================================================================
i_line_rule_cut( get_line_invoice, [
%=======================================================================
	
	generic_item( [ line_item, s1, q10(tab) ] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ dummy, s1, tab ] )
	
	, generic_item( [ line_net_amount, d, q10(tab) ] )
	
	, read_ahead( generic_item( [ line_original_order_date, date, newline ] ) )
	
	, generic_item( [ delivery_date, date, newline ] )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	append( line_descr(s1), ` `, ``), newline
	
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

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).