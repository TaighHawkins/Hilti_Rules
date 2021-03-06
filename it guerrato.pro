%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT GUERRATO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_guerrato, `15 May 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_buyer_contact
	
	, get_delivery_contact

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals
	
	, get_customer_comments
	
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
	  [ test(test_flag), suppliers_code_for_buyer( `12961180` ) ]    %TEST
	    , suppliers_code_for_buyer( `12961180` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )
	
	, delivery_party( `GUERRATO SPA` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line), generic_horizontal_details( [ [ `ORDINE`, `N`, `.` ], 200, order_number, s1, tab ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Rovigo`, `il` ], invoice_date, date ] )
	  
] ).


%=======================================================================
i_rule( get_customer_comments, [ with( invoice, shipping_instructions, Ship ), customer_comments( Ship ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Rif`, `.`, `Ns`, `.` ], buyer_contact_x, s1 ] )
	  
	, check( buyer_contact_x = Con_x )
	
	, check( sys_string_split( Con_x, ` `, Con_x_list ) )
	
	, check( sys_reverse( Con_x_list, Con_x_rev ) )
	
	, check( sys_stringlist_concat( Con_x_rev, ` `, Con ) )
	
	, buyer_contact( Con )

] ).

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,40,line), generic_vertical_details( [ [ `CAPO`, `COMMESSA` ], `CAPO`, end, delivery_contact_x, s1, tab ] )
	  
	, check( delivery_contact_x = Con_x )
	
	, check( sys_string_split( Con_x, ` `, Con_x_list ) )
	
	, check( sys_reverse( Con_x_list, Con_x_rev ) )
	
	, check( sys_stringlist_concat( Con_x_rev, ` `, Con ) )
	
	, delivery_contact( Con )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(0,35,line), delivery_header_line

	, delivery_thing( [ delivery_dept ] )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_city_state_line
	
	, delivery_address_line_line
	
] ).

%=======================================================================
i_line_rule( delivery_header_line, [ q0n(anything), read_ahead( [ `COMMESSA`, `:` ] ), delivery_hook(w) ] ).
%=======================================================================
i_line_rule( delivery_address_line_line, [ retab( [ 100 ] ), generic_item( [ delivery_address_line, s1, tab ] ) ] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [
%=======================================================================

	  nearest( delivery_hook(start), 10, 20 )
	  
	, Read_Variable
	
	, gen_eof
	
	, trace( [ String, Variable ] )

] ):-

	  Read_Variable =.. [ Variable, s1 ]
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_line_rule( delivery_postcode_city_state_line, [
%=======================================================================

	  nearest( delivery_hook(start), 10, 20 )
	  
	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
	
	, delivery_city(s1), tab
	
	, delivery_state( f( [ begin, q(alpha,2,2), end ] ) )
	
	, trace( [ `delivery stuffs`, delivery_city, delivery_state, delivery_postcode ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CIG CUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_cig_cup, [ 
%=======================================================================

	q0n(line), cig_cup_line
	
	, check( cup = Cup )
	, check( cig = Cig )
	
	, check( strcat_list( [ `CIG:`, Cig, ` CUP:`, Cup ], AL ) )
	, delivery_address_line( AL )
	, trace( [ `Delivery Address Line`, delivery_address_line ] )

] ).

%=======================================================================
i_line_rule( cig_cup_line, [ 
%=======================================================================

	q(2,2,
		[ q0n(anything)
			, or( [ [ peek_fails( test( got_cig ) ), `CIG`, `:`, cig(w), set( got_cig ) ]
			
				, [ peek_fails( test( got_cup ) ), `:`, `CUP`, cup(w), set( got_cup ) ]
			] )
		]
	)	

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

	q10( [ `€`, q10( tab ) ] )
	
	, read_ahead( [ total_net(d) ] )
	
	, total_invoice(d)
	
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

	, qn0( some_heading_line( 1, -450, 450 ) )

	, qn0( [

		  or( [ 
		
			  line_invoice_rule

			, some_line( 1, -450, 450 )

		] )

	] )
	
	, peek_ahead( gen_count_lines( [ line_end_line, Count ] ) )
	
	, shipping_instructons_line( Count, -450, 450 )

	, line_end_line

] ).


%=======================================================================
i_line_rule( some_heading_line, [
%=======================================================================

	 q10( [ 
		peek_fails( 
			or( [ item_code_prefixes
				, some( f( [ q(dec,4,10) ] ) ) 
			] ) 
		)
	 
		, generic_item( [ some_heading, s1 ] ) 
	
	] )
	
	, newline  

] ).

%=======================================================================
i_line_rule( some_line, [ q10( [ read_ahead( generic_item( [ dummy, s1 ] ) ), `.` ] ), newline ] ).
%=======================================================================
i_line_rule( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline  ] ).
%=======================================================================
i_line_rule_cut( shipping_instructons_line, [ generic_item( [ shipping_instructions, s1 ] ), qn0( [ tab, append( shipping_instructions(s1), ` `, `` ) ] ), newline  ] ).
%=======================================================================
i_line_rule_cut( line_header_line, [ `D`, `E`, `S`, `C`, `R`, `I`, `Z`, `I`, `O`, `N`, `E`  ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	  or( [ [ `VISTO`, `RESP` ]
	
	] )
	  
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  or( [ line_item_line( 1, -450, 450 ), set( item_in_descr ) ] )
	
	, q0n( some_line( 1, -450, 450 ) )
	
	, q10( [ generic_line( 1, -450, 450, [ generic_item( [ line_descr, s1, newline ] ) ] ), set( got_descr ) ] )
	
	, q0n( some_line( 1, -450, 450 ) )
	
	, line_invoice_line( 1, -450, 450 )
	
	, trace( [ `finished line` ] )

	, q( 10,0, or( [ [ test( item_in_descr ), line_continuation_line( 1, -450, 450 ) ]
	
			, [ some_line( 1, -450, 450 ), trace( [ `line skipped` ] ) ]
			
		] )
		
	), clear( item_in_descr )
	
	, trace( [ `finished rule` ] )
	, clear( got_descr )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  or( [ [ test( item_in_descr ), `>`, or( [ [ `Art`, `.` ], [ q10( tab ), `"`, q10( tab ) ] ] ), generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] ) ]
	  
		, peek_fails( test( item_in_descr ) )
		
	] )
	
	, or( [ [ test( got_descr ), append( line_descr(s1), ` `, `` ), tab ]
	
		, [ peek_fails( test( got_descr ) ), generic_item( [ line_descr, s1, tab ] ) ]
		
	] )

	, generic_item( [ line_quantity_uom_code, wf, [ q10( `.` ), tab ] ] )

	, or( [ [ test( item_in_descr ), generic_item( [ line_quantity, d, newline ] )

			, trace( [ `finished short line` ] )
			
		]
	
		, [ generic_item( [ line_quantity, d, tab ] )

			, generic_item( [ line_unit_amount, d, tab ] )
	
			, generic_item( [ line_net_amount, d, newline ] )
			
		]
		
	] )
	
] ).

%=======================================================================
i_rule( item_code_prefixes, [
%=======================================================================

	 or( [ 
		`Cod`
		, `Art`
		, `-`
		, `Codice`
		, `articolo`
		, `>`	
	] )

] ).
	
%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  qn0( or( [ item_code_prefixes, `.` ] ) )

	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], newline ] )
	
] ).