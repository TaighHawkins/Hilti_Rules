%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT ROCCHEGGIANI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_roccheggiani, `31 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%
%	DON'T DO ANMY MORE WORK FOR FREE ON LINE LEVEL DATA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date
	
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
	  [ test(test_flag), suppliers_code_for_buyer( `13003578` ) ]    %TEST
	    , suppliers_code_for_buyer( `13003578` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), delivery_note_number( `13003578` ) ]    %TEST
	    , delivery_note_number( `13003578` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )
	, sender_name( `Roccheggiani s.p.a.` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,30,line)
	  
	, generic_vertical_details( [ [ `Numero`, tab, `Serie` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,30,line)
	  
	, generic_vertical_details( [ [ `Data`, tab, `Numero` ], invoice_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	qn0(line)
	
	, generic_vertical_details( [ [ `Uffico`, `Acquisti` ], buyer_contact_x, s1, q10( [ tab, buyer_contact_y(s1), newline ] ) ] )
	
	, check( buyer_contact_x = X )
	, xor( [ check( buyer_contact_y = Y ), check( Y = `` ) ] )
	, check( strcat_list( [ X, ` `, Y ], Con ) )
	
	, buyer_contact( Con )
	, delivery_contact( Con )
	
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
	  
	, generic_horizontal_details( [ [ `Totale` ], 300, total_net, d ] )

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
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )

	, line_end_line
	
	, q10( [ q10( [ test( rif ), up, clear( rif ) ] )
	
		, customer_comments( `` )
	
		, qn0( generic_line( [ [ q10( [ num(d), tab ] ), append( customer_comments(s1), ``, ` ` ), newline ] ] ) )
		
		, generic_line( [ [ `Si`, `prega` ] ] )
		
	] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `n`, `.`, tab, `Codice`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ q10( [ num(d), tab ] )
			, or( [ [ `-`, `-`, `-` ], [ `Rif`, check( not( q_sys_comp_str_eq( num, `1` ) ) ), set( rif ) ] ] ) 
		]
		
		, [ `Si`, `prega` ]
		
		, [ `Annotazioni` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	line_invoice_line
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ no, d, q10( tab ) ] )

	, generic_item( [ codice, s1, tab ] )
	
	, line_descr(s), q01( [ tab, append( line_descr(s), ` `, `` ) ] )

	, or( [ [ peek_ahead( or( [ `(`, [ `Cod`, q10( `.` ), q10( tab ) ], `Codice` ] ) ), line_values_rule ]
	
		, [ newline, parent, line, line_values_line ]
		
	] )

] ).


%=======================================================================
i_line_rule_cut( line_values_line, [ line_values_rule ] ).
%=======================================================================
i_rule_cut( line_values_rule, [
%=======================================================================

	  q0n(word), or( [ `(`, [ `Cod`, q10( `.` ), q10( tab ) ], `Codice` ] ), q0n(word)
	  
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], [ q10( `)` ), tab ] ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )
	
	, q10( [ q10( `-` ), generic_item( [ line_percent_discount, d, tab ] ) ] )

	, generic_item( [ line_original_order_date, date, newline ] )

] ).


%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
] ).