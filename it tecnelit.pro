%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT ALPIQ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_alpiq, `17 February 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, street_two, `street two storage` ).

i_user_field( invoice, due_date_year, `due date year storage` ).

i_rules_file( `d_hilti_it_postcode.pro` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_emails_and_contacts
	
	, get_order_number
	
	, get_order_date
	
	, get_delivery_note_number
	
	, get_customer_comments

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
	    , suppliers_code_for_buyer( `13041583` )                      %PROD
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
	
	, wrap( buyer_dept( Head_Up ), `ITTECN`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITTECN`, `` )
	
] )
:-

	  i_mail( text, Clutter )
	  
	, q_sys_sub_string( Clutter, CEU_Start, _, `tecnelit.it` )

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
i_line_rule( order_header_line, [ `NUMERO`, tab, `COMMESSA` ] ).
%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), order_header_line
	  
	, order_number_line
	
] ).

%=======================================================================
i_line_rule( order_number_line, [
%=======================================================================	  
	  
	  wrap( order_number(s1), `NUM `, `` )
	  
	, tab, append( order_number(s1), ` COMMESSA `, `` )
	
	, trace( [ `order number`, order_number ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,10,line), generic_vertical_details( [ [ `DATA`, `COMPILAZIONE` ], `DATA`, end, invoice_date, date, gen_eof ] ) 
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_number, [ 
%=======================================================================

	  q(0,10,line), generic_vertical_details( [ [ `LUOGO`, `CONSEGNA` ], `LUOGO`, end, delivery_note_number, s1, tab ] ) 
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `COMMESSA`, `N`, `:` ], 300, customer_comments, s1, tab ] )
	  
	, second_customer_comments_line
	
] ).

%=======================================================================
i_line_rule( second_customer_comments_line, [
%=======================================================================	  
	  
	  nearest( customer_comments(start), 5, 30 )
	  
	, append( customer_comments(s1), ` `, `` )
	
	, check( customer_comments = Ship )
	
	, shipping_instructions( Ship )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ qn0(line), totals_line ] ).
%=======================================================================	 
i_line_rule( totals_line, [ 
%=======================================================================	 

	  read_ahead( [ total_net(d), tab(300), something(s1) ] )
	  
	, generic_item( [ total_invoice, d, tab ] )
	
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
		
			  line_invoice_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `RICH`, tab, `MAG` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ num(d), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_no, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity, d, tab	] )
	
	, `HILTI`, tab

	, generic_item( [ line_item, s1, tab ] )
	
	, or( [ [ without( due_date ), generic_item( [ due_date, date, newline ] ) ]
	
		, [ with( due_date ), generic_item( [ some_date, date, newline ] ) ]
		
		, `"`, newline
		
	] )
	
	, q10( [ with( invoice, due_date, Due ), line_original_order_date( Due ) ] )

	, count_rule
	
	, line_net_amount( `1` )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).