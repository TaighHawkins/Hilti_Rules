%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT METALSISTEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_metalsistem, `19 February 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_emails_and_contacts
	
	, get_emails_and_contacts_old
	
	, get_order_number_and_date
	
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
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `12931924` )                      %PROD
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
	
	, wrap( buyer_dept( Head_Up ), `ITMETA`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITMETA`, `` )
	
	, set( got_email )
	
] )
:-

	  i_mail( text, Clutter )
	  
%	, trace( `started` )

	, q_sys_sub_string( Clutter, Domain_Start, Domain_Length, `@metalsistem.com` )
	
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
	
	, wrap( buyer_dept( Head_Up ), `ITMETA`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITMETA`, `` )
	
] )
:-

	  not( grammar_set( got_email ) )

	, i_mail( text, Clutter )

	, q_sys_sub_string( Clutter, CEU_Start, _, `metalsistem.com` )

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
i_rule( get_order_number_and_date, [ q(0,30, line ), order_number_and_date_line ] ).
%=======================================================================	  
i_line_rule( order_number_and_date_line, [
%=======================================================================	  
	  
	  `Ordine`, `Acquisto`, q10( tab )
	  
	, order_number(sf), q01( tab )
	
	, del, q10( tab )
	
	, invoice_date(date), q01( tab ), `Pag`
	
	, trace( [ `order number and invoice date`, order_number, invoice_date ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================
	  
	  q(0,35, line ), generic_horizontal_details( [ [ `Data`, `consegna` ], due_date, date, tab ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================	

	  or( [ [ q0n(line), generic_horizontal_details( [ read_ahead( [ `Luogo`, `di`, `consegna` ] ), delivery_hook, s1 ] )
			, generic_horizontal_details( [ nearest( delivery_hook(start), 10, 10 ), delivery_party, s1 ] )
			, set( alternate )
		]
	  
		, [ q0n(line), delivery_header_line ]
		
	] )
	
	, delivery_street_line
	
	, delivery_postcode_city_state_line
	
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
	  
	  generic_item( [ delivery_street, s1, newline ] )
	  
	, or( [ test( alternate ), check( delivery_street(start) > delivery_hook(end) ) ] )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_city_state_line, [ 
%=======================================================================
	  
	  q10( [ delivery_postcode(f( [ begin, q(dec,4,5), end ] ) ), q10( tab ) ] )
	  
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

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Valore`, `ordine` ], 200, total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `Valore`, `ordine` ], 200, total_invoice, d, newline ] )

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
i_line_rule_cut( line_header_line, [ `Codice`, `e`, `descrizione`, `parte` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Valore`, `ordine` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	  line_invoice_line
	  
	, read_ahead( [ q01( line ), line_item_line ] )
	
	, q10( line_discount_line )
	
	, with( invoice, due_date, Date )
	
	, line_original_order_date( Date )

	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), q01( [ tab, append( line_descr(s1), ` `, `` )] ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s, `q10`, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
		
	, generic_item( [ line_quantity, d, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule( line_item_line, [
%=======================================================================

	  trace( [ `getting item` ] )
	  
	, q0n(word), or( [ `COD`, `ART`, `RIF` ] ), `.`, q10( `:` ), q01( tab )
	  
	, line_item( f( [ begin, q(dec,4,10), end ] ) )
	
	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_line_rule( line_discount_line, [
%=======================================================================

	  trace( [ `looking for discount` ] )
	  
	, q0n(anything)
	  
	, `Sc`, `.`
	
	, generic_item( [ line_percent_discount, d, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).