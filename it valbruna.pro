%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT VALBRUNA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_valbruna, `12 May 2015` ).

%i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_contact_depts
	
	, get_alternate_depts
	
	, get_delivery_address
	
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
	  [ test(test_flag), suppliers_code_for_buyer( `17010320` ) ]    %TEST
	    , suppliers_code_for_buyer( `17010320` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMAIL ADDRESSES + TWEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_depts, [
%=======================================================================

	  wrap( buyer_dept( Head_Up ), `ITVALB`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITVALB`, `` )
	
	, trace( [ `Got original` ] )
	
] )
:-

	  i_mail( text, Clutter )
	  
%	, trace( `started` )

	, ( q_sys_sub_string( Clutter, Domain_Start, Domain_Length, `@valbruna.it` )
		; q_sys_sub_string( Clutter, Domain_Start, Domain_Length, `@LEGALMAIL.IT` )
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

	, strip_string2_from_string1( Head, `.-`, Head_Nodot )

	, sys_string_length( Head_Nodot, Len )

	, ( q_sys_comp( Len >= 11 ) 
	
		->	q_sys_sub_string( Head_Nodot, 1, 11, Head_10 )
		
		; Head_10 = Head_Nodot 
	
	)
	
	, string_to_upper( Head_10, Head_Up )
	
	, trace( `finished prologue-y bit` )
	
	, !
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMAIL ADDRESSES + TWEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_alternate_depts, [
%=======================================================================

	  wrap( buyer_dept( Head_Up ), `ITVALB`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITVALB`, `` )
	
	, trace( [ `Got Alternate` ] )
	
] )
:-

	  i_mail( text, Clutter )

	, ( q_sys_sub_string( Clutter, CEU_Start, _, `@valbruna.it` )
		; q_sys_sub_string( Clutter, CEU_Start, _, `@LEGALMAIL.IT` )
	), !
	
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
	  
	  q(0,20,line)
	  
	, generic_horizontal_details( [ [ tab, `Nro`, `.` ], order_number, sf
									, [ q10( tab ), `Data`, `:`, generic_item( [ invoice_date, date ] ) ] 
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
	, generic_horizontal_details( [ [ `Indirizzo`, `Destinatario` ] ] )
	
	, q(0,3,line)
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), `Rag`, `.`, `Sociale`, `:` ], delivery_party, s1 ] )
	
	, q(0,3,line)	
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), `Indirizzo`, `:` ], delivery_street, s1 ] )
	
	, q(0,3,line)	
	, delivery_city_state_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	q0n( [ dummy(s1), tab ] )
	
	, `Localita`, `:`, q10( tab )
	
	, generic_item( [ delivery_city, sf, or( [ read_ahead(num(d)), tab ] ) ] )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, q10( tab ), generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
	
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
	  
	, generic_horizontal_details( [ [ `Totale`, `*`, `*` ], total_net, d ] )

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
			  
			, line_discount_line
			
			, line_comments_rule

			, line_continuation_line
			
			, line

		] )

	] )

	, line_end_line 

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `POS`, tab, `Codice`, tab, `-`, tab, `Descrizione` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `*`, `*`, `*` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	line_item_line
	
	, line_invoice_line
	
	, q10( [ q(0,3,line), generic_line( [ [ `sconti`, `vari`, tab, `-`, generic_item( [ line_percent_discount, d ] ) ] ] ) ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_descr, s1, tab ] )

	, generic_item( [ line_original_order_date, date, q10( tab ) ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_unit_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_discount_line, [ `-`, generic_item( [ line_percent_discount, d, `%` ] ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [ 
%=======================================================================

	generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )
	
	, generic_item( [ line_item_for_buyer, [ begin, q(dec,4,10), end ], newline ] ) 
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================

%=======================================================================
i_rule_cut( line_comments_rule, [ 
%=======================================================================

	read_ahead( [ line, generic_line( [ [ read_ahead( [ q0n(word), `ATTENZIONE` ] ), attention(s1) ] ] ) ] )
	
	, comments
	
	, check( comments(y) = Com )
	, check( attention(y) = Att )
	, check( sys_calculate( Diff, Att - Com ) )
	, check( Diff < 30 )
	
	, generic_line( [ generic_item( [ customer_comments, s1, newline ] ) ] )
	
] ).


%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
] ).