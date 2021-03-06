%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT A&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_a_and_t, `24 October 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, due_date_year, `due date year storage` ).

i_rules_file( `d_hilti_it_postcode.pro` ).


%=======================================================================
i_page_split_rule_list( [ check_for_new_order_format ] ).
%=======================================================================
i_section( check_for_new_order_format, [ new_order_format_line ] ).
%=======================================================================
i_line_rule( new_order_format_line, [
%=======================================================================
	check_text( `POSARTICOLODESCRIZIONE` )
	, set( chain, `it a and t` )
	, trace( [ `CHAINING TO NEW FORMAT` ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_emails_and_contacts
	
	, get_order_number
	
	, get_order_date

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
	    , suppliers_code_for_buyer( `12999077` )                      %PROD
	]) ]  
	
	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10658906` ) ]    %TEST
	    , delivery_note_number( `12999077` )                      %PROD
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
	
	, wrap( buyer_dept( Head_Up ), `ITAT`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITAT`, `` )
	
] )
:-

	  i_mail( text, Clutter )
	  
	, q_sys_sub_string( Clutter, CEU_Start, _, `piscinecastiglione.it` )
	  
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
	  
	  q(0,3,line), generic_horizontal_details( [ [ `ORDINE`, `DI`, `ACQUISTO` ], order_number, s1, tab ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [ q(0,3,line), order_date_line ] ).
%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================
	  
	  q0n(anything)
	  
	, `DATA`, `:`, q01( tab )
	
	, invoice_date(d), `-`
	
	, append( invoice_date(d), `/`, `/` ), `-`
	
	, append( invoice_date(d), ``, `` )
	
	, trace( [ `order date`, invoice_date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `TOTALE`, `:`, q10( `€` ) ], 200, total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `TOTALE`, `:`, q10( `€` ) ], 200, total_invoice, d, newline ] )

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
			  
			, line_continuation_line
			
			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ q10( [ `VALORE`, tab ] ), `RICHIESTA`, `:`, newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `TOTALE`, `:` ], [ `Per`, `l`, `'`, `esatta` ] ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ line_invoice_line, or( [ [ q(0,2,line_continuation_line), read_ahead( line_item_line ) ], line_item_x( `Missing` ) ] ) ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), q01( [ tab, append( line_descr(s1), ` `, `` )] ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  retab( [ -373, -20, 63, 140, 240, 326 ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, tab ] )
	
	, generic_item( [ line_original_order_date, date, newline ] )

	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  `VS`, q10( `.` )
	  
	, or( [ `Rif`, `COD` ] ), `.`
	  
	, line_item_x( f( [ begin, q(dec,4,10), end ] ) )
	
	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).