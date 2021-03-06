%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT TEA CO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_tea_co, `27 April 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, street_two, `street two storage` ).

i_user_field( invoice, due_date_year, `due date year storage` ).

i_rules_file( `d_hilti_it_postcode.pro` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_data_at_location( [ order_number, s1, -310, -270, -120, 10 ] )

	, get_data_at_location( [ invoice_date, date, -310, -270, 70, 180 ] )
	
	, get_emails_and_contacts
	
	, get_delivery_address
	
	, get_shipping_instructions

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
	    , suppliers_code_for_buyer( `13032270` )                      %PROD
	]) ]    

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMAIL ADDRESSES + TWEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_emails_and_contacts, [
%=======================================================================

	  buyer_email( Email )
	  
	, delivery_email( Email )
	
	, trace( [ `emails`, delivery_email ] )
	
	, wrap( buyer_dept( Head_Up ), `ITTEA`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITTEA`, `` )
	
] )
:-

	  i_mail( text, Clutter )
	  
	, q_sys_sub_string( Clutter, CEU_Start, _, `teaco.it` )
	  
	, q_sys_sub_string( Clutter, Start, _, `mailto` )
	
	, sys_calculate( Difference, CEU_Start - Start )
	
	, q_sys_comp( Difference =< 50 )
	
	, q_sys_sub_string( Clutter, Start, _, Less_Clutter )

	, q_sys_sub_string( Less_Clutter, Colon, _, `:` )
	
	, sys_calculate( Colon_plus, Colon + 1 )
	
	, ( q_sys_sub_string( Less_Clutter, Email_End, _, `"` )
	
		; q_sys_sub_string( Less_Clutter, Email_End, _, `]` )
		
		; q_sys_sub_string( Less_Clutter, Email_End, _, `<` )
		
	)
	
	, sys_calculate( Length, Email_End - Colon_plus )
		
	, q_sys_sub_string( Less_Clutter, Colon_plus, Length, Email )

	, sys_string_split( Email, `@`, [ Head | _ ] )

	, strip_string2_from_string1( Head, `.`, Head_Nodot )

	, sys_string_length( Head_Nodot, Len )

	, ( q_sys_comp( Len >= 10 ) 
	
		-> q_sys_sub_string( Head_Nodot, 1, 10, Head_10 )
		
	; Head_10 = Head_Nodot 
	
	)
	
	, string_to_upper( Head_10, Head_Up )
	
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ or( [ map_the_address, without_an_address ] ) ] ).  
%=======================================================================
i_rule( map_the_address, [ 
%======================================================================= 	  
	  
	  trace( [ `trying to map` ] )
	  
	, q0n(line), delivery_party_dept_line
	  
	, delivery_address_line_line
	
	, or( [ with( delivery_postcode )
	
		, [ check( i_user_check( find_the_postcode, PC, delivery_city, delivery_location, Unknown ) )
	
			, delivery_postcode( PC )
		]
	] )
	
	, q10( check_for_location_rules ) 
	
] ).

%=======================================================================
i_line_rule_cut( delivery_party_dept_line, [
%=======================================================================

	  delivery_party(sf)
	  
	, check( delivery_party(y) > 400 )
	
	, trace( [ `found the delivery party`, delivery_party ] )

	, read_ahead( [ `c`, `/`, `o` ] )
	
	, delivery_dept(s1)
	
	, trace( [ `delivery party and dept`, delivery_party, delivery_dept ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_address_line_line, [
%=======================================================================

	  generic_item( [ delivery_street, s1, tab ] )
	
	, q10( generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ], q10( tab ) ] ) )

	, generic_item( [ delivery_city, s, [ q10( tab ), generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ], newline ] ) ] ] )

] ).

%=======================================================================
i_rule( without_an_address, [
%=======================================================================

	  or( [ [ test( test_flag ), delivery_note_number( `11205719` ) ]
		, delivery_note_number( `13032270` )
	] )

] ).

%=======================================================================
i_user_check( find_the_postcode, PC, City_L, State, Unknown )
%---------------------------------------
:-
%=======================================================================

	  string_to_upper( City_L, City )
	
	,(	postcode_lookup( PC, City, State, _ )
	
		;   postcode_lookup( PC, City, _, _ )
	
		;	PC = `Missing` 
	
	)
.

%=======================================================================
i_rule( check_for_location_rules, [
%=======================================================================

	check( delivery_street = Street )
	, check( string_to_lower( Street, StreetL ) )
	
	, or( [ [ check( q_sys_sub_string( StreetL, _, _, `p.za malan - san donate m.se` ) )
			, delivery_location( `P .ZA MALAN` )
		]
		
		, [ check( q_sys_sub_string( StreetL, _, _, `via morandi,30 san donate m.se` ) )
			, delivery_location( `VIA MORANDI,30` )
		]		
		, [ check( q_sys_sub_string( StreetL, _, _, `via r.galeazzi,3 -milano-` ) )
			, delivery_location( `ORTOPEDICO GALEAZZI` )
		]
	] )
	
	, remove( delivery_street )
	, remove( delivery_postcode )
	, remove( delivery_state )
	, remove( delivery_dept )
	, remove( delivery_city )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS LINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ q0n(line), get_shipping_instructions_line] ).  
%=======================================================================
i_line_rule( get_shipping_instructions_line, [ 
%======================================================================= 	  
	  
	  shipping_instructions(s1), newline
	  
	, check( shipping_instructions(y) > 370 )
	
	, check( shipping_instructions(y) < -400 )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `TOTALE`, `ORDINE`, tab, `EURO` ], 150, total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `TOTALE`, `ORDINE`, tab, `EURO` ], 150, total_invoice, d, newline ] )

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
		
			  line_original_order_date_line
				
			, line_unit_amount_line
		
			, line_invoice_line
			
			, line

		] )

	] )
		
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ header(s1), check( header(y) < -240 ), check( header(y) > -250 ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ q0n(anything), `TOTALE`, `ORDINE` ] 
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  retab( [ -290, -30, 10, 108, 280, 420 ] )
	  
	, line_item( f( [ q(alpha("HI"),0,2), begin, q(dec,4,10), end ] ) ), tab
	
	, trace( [ `line item`, line_item ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, line_quantity( fd( [ begin, q([dec,other(".")],1,10), q(other(","),1,1), q(dec,3,3), end ] ) ), tab
	
	, trace( [ `line qty`, line_quantity ] )

	, or( [ [ without( customer_comments ), generic_item( [ customer_comments, s1, tab ] ) ]
	
		, [ with( customer_comments ), append( customer_comments(s1), `~`, `` ), tab ]
		
		, tab
		
	] )

	, generic_item( [ commessa, s1, tab ] )
	
	, generic_item( [ type, w, newline ] )

	, count_rule

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_line_rule_cut( line_unit_amount_line, [
%=======================================================================

	  q0n(word)
	  
	, `/`, word, tab
	
	, line_unit_amount( fd( [ begin, q([dec,other(".")],1,10), q(other(","),1,1), q(dec,3,5), end ] ) )
	
	, newline
	
	, trace( [ `line unit`, line_unit_amount ] )

] ).

%=======================================================================
i_line_rule_cut( line_original_order_date_line, [
%=======================================================================

	  q0n(word)
	  
	, `Data`, q0n(word)
	
	, line_original_order_date(date), newline
	
	, trace( [ `line date`, line_original_order_date ] )

] ).

%=======================================================================
i_rule( get_data_at_location( [ Variable, Parameter, Y_above, Y_below, X_before, X_after ] ), [ 
%=======================================================================

	  q(0,20,line), find_the_data( [ Variable, Parameter, Y_above, Y_below, X_before, X_after ] )
	
] ).

%=======================================================================
i_line_rule( find_the_data( [ Variable, Parameter, Y_above, Y_below, X_before, X_after ] ), [ 
%=======================================================================

	  check_the_y( [ Y_above, Y_below ] )
	  
	, q0n(anything)
	
	, Read_Variable
	
	, check( Check_Start > X_before )
	
	, check( Check_End < X_after )
	
	, trace( [ Variable_S, Variable ] )

] )
:-
	  sys_string_atom( Variable_S, Variable )
	  
	, Read_Variable =.. [ Variable, Parameter ]
	
	, Check_Start =.. [ Variable, start ]
	
	, Check_End =.. [ Variable, end ]
.

%=======================================================================
i_rule( check_the_y( [ Y_above, Y_below ] ), [ 
%=======================================================================

	  read_ahead( dummy(w) )
	  
	, check( dummy(y) < Y_below )
	
	, check( dummy(y) > Y_above )
	
	, trace( [ `found line` ] )

] ).