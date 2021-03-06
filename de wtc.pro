%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE WTC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_wtc, `27 May 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_order_number
	
	, get_invoice_date
	
	, get_due_date
	
	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_delivery_details

	, get_contacts

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

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


	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, suppliers_code_for_buyer( `10174046` )
	
	, delivery_party( `WTC Wärmetechnik` )
	
	, sender_name( `WTC Warmetechnik Chemnitz GmbH & Co.` )

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
	  
	, generic_horizontal_details( [ [ `Bestell`, `-`, `Nr`, `:` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_invoice_date, [
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ or( [ at_start, tab ] ), invoice_date, date ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  
	  
	  q(0,30,[ line, peek_fails( line_header_line ) ] )
	  
	, generic_horizontal_details( [ [ `Lieferdatum`, `:` ], 150, due_date, date
		, [ `/`, q10( [ something(s1), set( do_not_process ), delivery_note_reference( `special_rule` ) ] ) ]
	] )
	
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
	  
	, generic_horizontal_details( [ [ `Sachbearbeiter`, `:` ], contact, s1 ] )
	
	, check( contact = Con )
	, check( string_to_upper( Con, ConU ) )
	, check( string_string_replace( ConU, `Ä`, `AE`, ConRep ) )
	, check( string_string_replace( ConRep, `Ü`, `UE`, ConRep1 ) )
	, check( string_string_replace( ConRep1, `Ö`, `OE`, ConRep2 ) )
	, check( string_string_replace( ConRep2, `ß`, `SS`, ConRep3 ) )
	, check( strip_string2_from_string1( ConRep3, ` `, ConStrip ) )
	, check( strcat_list( [ `DEWTC`, ConStrip ], ConLong ) )
	
	, or( [ [ check( sys_string_length( ConLong, ConLen ) )
			, check( ConLen < 17 )
			, check( ConLong = LIFNR )
		]
		
		, check( q_sys_sub_string( ConLong, 1, 17, LIFNR ) )
	] )
	
	, buyer_dept( LIFNR )
	, delivery_from_contact( LIFNR )

	, trace( [ `Contact LIFNR`, LIFNR ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q0n(line), generic_horizontal_details( [ [ `Lieferadresse` ] ] )
	  
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )

	, generic_horizontal_details_cut( [ nearest( generic_hook(start), 10, 10 ), delivery_dept_x, s1 ] )
	, check( delivery_dept_x = DeptX )
	, check( string_string_replace( DeptX, `Baustelle:`, `BV:`, Dept ) )
	, delivery_dept( Dept )

	, q(2,0,
		[ qn0( gen_line_nothing_here( [ delivery_dept_x(start), 10, 10 ] ) )
			, generic_horizontal_details_cut( [ nearest( delivery_dept_x(start), 10, 10 ), delivery_address_line, s1 ] )
		]
	)

	, qn0( gen_line_nothing_here( [ delivery_dept_x(start), 10, 10 ] ) )
	, generic_horizontal_details_cut( [ nearest( delivery_dept_x(start), 10, 10 ), delivery_street, s1 ] )

	, qn0( gen_line_nothing_here( [ delivery_dept_x(start), 10, 10 ] ) )
	, delivery_street_and_city_line

	, q10( [ 
		qn0( gen_line_nothing_here( [ delivery_dept_x(start), 10, 70 ] ) )
		, generic_horizontal_details( [ nearest( delivery_dept_x(start), 10, 10 ), customer_comments, s1 ] )
		, check( customer_comments = Com )
		, shipping_instructions( Com )
	] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_and_city_line, [
%=======================================================================

	  nearest( delivery_dept_x(start), 10, 10 )
	  
	, set( regexp_allow_partial_matching )
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ], peek_fails( dum( f( [ q(dec,1,1) ] ) ) ) ] )
	, clear( regexp_allow_partial_matching )
	
	, generic_item( [ delivery_city, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Gesamtpreis`, `netto` ], total_net, d ] ) )
	  
	, check( total_net = Net )
	, total_invoice( Net )

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

	, qn0(

		or( [ 
		
			  line_invoice_rule

			, line

		] )

	)

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `lfd`, `.`, `Nr`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Gesamtpreis`, `netto` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]

	] )
	
] ).


%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, with( invoice, due_date, Date ), line_original_order_date( Date )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )
	  
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )

	, generic_item( [ line_quantity_uom_code, w, q10( tab ) ] )

	, generic_item_cut( [ line_unit_amount, d, [ `€`, q10( [ `/`, word ] ), tab ] ] )

	, generic_item_cut( [ line_net_amount, d, [ `€`, newline ] ] )

] ).