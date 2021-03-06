%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT GARC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_garc, `03 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_op_param( xml_transform( delivery_street, In ), _, _, _, Out )
:-
	strip_string2_from_string1( In, `,`, Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_emails_and_contacts
	, get_emails_and_contacts_old
	
	, get_order_number
	
	, get_order_date
	
	, get_due_date
	
	, get_delivery_details
	
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
	  [ test(test_flag), suppliers_code_for_buyer( `12957309` ) ]    %TEST
	    , suppliers_code_for_buyer( `12957309` )                      %PROD
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
	
	, wrap( buyer_dept( Head_Up ), `ITGARC`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITGARC`, `` )
	
	, set( got_email )
	
] )
:-

	  i_mail( text, Clutter )
	  
%	, trace( `started` )

	, ( q_sys_sub_string( Clutter, Domain_Start, Domain_Length, `garcspa.it` )
		;	q_sys_sub_string( Clutter, Domain_Start, Domain_Length, `garc.it` )
		;	q_sys_sub_string( Clutter, Domain_Start, Domain_Length, `pec.it` )
	)
	
	, !
	
	, q_sys_sub_string( Clutter, User_Start, User_Length, `User` )
	
	, sys_calculate( Domain_End, Domain_Length + Domain_Start )
	
	, sys_calculate( User_Location, User_Start + User_Length )
	
	, sys_calculate( Trimmed_Length, Domain_End - User_Location )
	
	, q_sys_sub_string( Clutter, User_Location, Trimmed_Length, Less_Clutter )
	
	, !

%	, trace( less_clutter( Less_Clutter ) )
	
	, q_sys_sub_string( Less_Clutter, Before_Email, _, `(` )
	
	, sys_calculate( Email_Start, Before_Email + 1 )
	
%	, trace( email_start( Email_Start ) )
	
	, sys_calculate( Email_Length_x, Domain_End - Email_Start )
	
	, sys_calculate( Email_Length_y, Email_Length_x - User_Location )
	
	, sys_calculate( Email_Length, Email_Length_y + 1 )
	
%	, trace( email_length( Email_Length ) )
	
	, q_sys_sub_string( Less_Clutter, Email_Start, Email_Length, Email )
	
%	, trace( pot_email( Email ) )

	, sys_string_split( Email, `@`, [ Head | _ ] )
	
%	, trace( split_email( Head ) )

	, strip_string2_from_string1( Head, `.`, Head_Nodot )

	, sys_string_length( Head_Nodot, Len )

	, ( q_sys_comp( Len >= 10 ) 
	
		->	q_sys_sub_string( Head_Nodot, 1, 10, Head_10 )
		
		; Head_10 = Head_Nodot 
	
	)
	
	, string_to_upper( Head_10, Head_Up )
	
	, trace( `finished prologue-y bit` )
	
	, !
.

%=======================================================================
i_rule( get_emails_and_contacts_old, [
%=======================================================================

	  buyer_email( Email )

	, delivery_email( Email )
	
	, trace( [ `emails`, delivery_email ] )
	
	, wrap( buyer_dept( Head_Up ), `ITGARC`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITGARC`, `` )
	
] )
:-

	  not( grammar_set( got_email ) )

	, i_mail( text, Clutter )

	, ( q_sys_sub_string( Clutter, CEU_Start, _, `garcspa.it` )
		;	q_sys_sub_string( Clutter, CEU_Start, _, `garc.it` )
		;	q_sys_sub_string( Clutter, CEU_Start, _, `pec.it` )
	)

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
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ `Ordine`, `N`, `°` ], order_number, sf, [ q10( `.` ), gen_eof ] ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================
	  
	  q(0,35,line), generic_horizontal_details( [ `Data`, invoice_date, date ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================
	  
	  q(0,35,line), generic_horizontal_details( [ [ `Data`, `consegna` ], due_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================	

	  or( [ [ q(0,20,line), generic_horizontal_details( [ [ `Destinazione`, `Merce` ] ] )
	
			, generic_horizontal_details( [ [ nearest( generic_hook(start), 10, 10 ), q10( [ num(d), q10( `-` ) ] ) ], delivery_party, s1 ] )
			
			, q10( [ 
				q(2,0, gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
				, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10)
					, additional_party, s1, check( delivery_party(font) = additional_party(font) ) 
				] )
				, check( additional_party = Party )
				, append( delivery_party( Party ), ` `, `` )
			] )
			
			, q(2,0, gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
			, delivery_street_line
			
			, q(2,0, gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
			, delivery_postcode_city_state_line
		]
		
		, delivery_note_number( `12957309` )
	] )
	
] ).
  
%=======================================================================	  
i_line_rule( delivery_header_line, [
%=======================================================================	  
	  
	  `Luogo`, `di`, read_ahead( `destinazione` )
	  
	, delivery_hook(w), `:`
	
	, generic_item( [ delivery_party, s1, newline ] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================
	  
	  nearest( generic_hook(start), 10, 10 )
	  
	, generic_item( [ delivery_street, s1, check( delivery_street(font) \= delivery_party(font ) ) ] )

] ).

%=======================================================================
i_line_rule( delivery_postcode_city_state_line, [ 
%=======================================================================
	  
	  nearest( generic_hook(start), 10, 10 )
	  
	, q10( [ delivery_postcode(f( [ begin, q(dec,4,5), end ] ) ), q10( tab ) ] )

	, generic_item( [ delivery_city, sf, or( [ tab, [ q10( `-` ), `(` ] ] ) ] )
	
	, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
	
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
	  
	, generic_vertical_details( [ [ `Totale`, `corpo` ], `corpo`, total_net, d ] )
	
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
	
	, or( [ peek_fails( test( get_instructions ) )
	
		, [ test( get_instructions )
			, peek_ahead( gen_count_lines( [ line_end_line, Count ] ) )
			, generic_line( Count, [ generic_item( [ shipping_instructions, s1 ] ) ] )
			, clear( get_instructions )
		]
	] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Codice`, tab, `Descrizione`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ `*`, `*`, `*`, set( get_instructions ) ]
		
		, [ `Totale`, `corpo` ]
		
		, [ dummy, check( header(page) \= dummy(page) ) ]
	] )
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  line_invoice_line
	
	, q10( [ with( invoice, due_date, Date )
		, line_original_order_date( Date )
	] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), q01( [ tab, append( line_descr(s1), ` `, `` )] ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d ] )
	  
	, generic_item( [ line_item, f( [ q(alpha("HIL"),0,3), begin, q(dec,4,10), end ] ), tab ] )

	, generic_item_cut( [ line_descr, s, [ q10(tab), check( line_descr(end) < header(start) ) ] ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, q10( generic_item_cut( [ line_percent_discount, d, tab ] ) )
	
	, generic_item_cut( [ line_net_amount, d, tab ] )
	
	, generic_item( [ vat, d, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).