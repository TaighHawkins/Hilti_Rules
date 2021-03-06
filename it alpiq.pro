%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT ALPIQ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_alpiq, `21 February 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, street_two, `street two storage` ).

i_user_field( invoice, due_date_year, `due date year storage` ).

i_rules_file( `d_hilti_it_postcode.pro` ).


i_page_split_rule_list( [ check_for_new_format ] ).
i_section( check_for_new_format, [ check_for_new_format_line ] ).
i_line_rule( check_for_new_format_line, [ 

	check_text( `POSIZCODICEALPIQDESCRIZIONECOMMESSAUMQUANTITAPREZZO%%%TOTALECONSEGNAIVA` )
	, set( chain, `it alpiq 2` )
	, trace( [ `Chaining to new format` ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_emails_and_contacts
	
	, get_order_number
	
	, get_order_date
	
	, get_delivery_details

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, total_net( `0` )
	
	, total_invoice( `0` )	

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
	    , suppliers_code_for_buyer( `13139417` )                      %PROD
	]) ]  

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
	
	, wrap( buyer_dept( Head_Up ), `ITALPI`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITALPI`, `` )
	
] )
:-

	  i_mail( text, Clutter )
	  
	, q_sys_sub_string( Clutter, CEU_Start, _, `alpiq.com` )
	  
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
	  
	  q(0,10,line), generic_vertical_details( [ [ `Commessa`, `:` ], `Commessa`, start, order_number, s1, tab ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ q(0,10,line), order_date_line ] ).
%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================
	  
	  dummy(s1), tab
	  	
	, invoice_date(d), qn1( `\\` )
	
	, append( invoice_date(d), `/`, `/` ), qn1( `\\` )
	
	, append( invoice_date(d), ``, `` )
	
	, trace( [ `order date`, invoice_date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================	  
	
	  qn0( line ), delivery_header_line
	  
	, delivery_thing( [ delivery_party ] )
	
	, delivery_thing( [ delivery_dept ] )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_thing( [ delivery_city ] )
	
	, postcode_lookup_rule
	
] ).

%=======================================================================
i_line_rule( delivery_header_line, [ `Fornitori`, `consigliati`, `o`, `imposti`, `:`, tab, delivery_hook(s1) ] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [ 
%=======================================================================
	  
	  nearest( delivery_hook(start), 10, 10 )
		
	, Read_Var
	
	, trace( [ String, Variable ] )
	
] )
:-
	  Read_Var =.. [ Variable, s1 ]
	
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_rule( postcode_lookup_rule, [
%=======================================================================	  
	 	
	  check( i_user_check( find_the_postcode, PC, delivery_city, Loc, Unknown ) )
	
	, delivery_postcode( PC )
		
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
		
			  line_invoice_line
			  
			, line_check_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, `Merc`  ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Documentazione`, `a` ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_no, s1, tab ] )

	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, q10( [ word, q10( tab ) ] )
	
	, generic_item( [ line_quantity, d, newline ] )

	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_check_line, [
%=======================================================================

	  q0n(anything)
	  
	, dummy(d)
	
	, check( dummy(start) > 50 )
	
	, force_result( `defect` )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).