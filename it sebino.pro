%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT SEBINO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_sebino, `05 March 2015` ).

%i_pdf_parameter( same_line, 6 ).

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

	, get_order_number

	, get_contact_depts
	
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
	  [ test(test_flag), suppliers_code_for_buyer( `18865064` ) ]    %TEST
	    , suppliers_code_for_buyer( `18865064` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Sebino Fire Protection` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMAIL ADDRESSES + TWEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_depts, [
%=======================================================================

	  wrap( buyer_dept( Head_Up ), `ITSEB`, `` )
	
	, wrap( delivery_from_contact( Head_Up ), `ITSEB`, `` )
	
	, trace( [ `Contacts`, Head_Up ] )
	
] )
:-

	  i_mail( text, Clutter )
	  
%	, trace( `started` )

	, q_sys_sub_string( Clutter, Domain_Start, Domain_Length, `@sebino.eu` )
	
	, !
	
	, q_sys_sub_string( Clutter, Start, _, `mailto` )
	
	, sys_calculate( Difference, Domain_Start - Start )
	
	, q_sys_comp( Difference =< 50 )
	
	, q_sys_sub_string( Clutter, Start, _, Less_Clutter )
	
	, !

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
	  
	, generic_vertical_details( [ [ `Numero`, tab, `Del` ], order_number, sf
									, [ q10( tab ), generic_item( [ invoice_date, date ] ) ] 
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
	, generic_horizontal_details( [ [ `Destinazione`, `merce` ] ] )
	
	, q(0,3,line)
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_party, s1 ] )
	
	, q(0,3,line)	
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 10 ), delivery_street, s1 ] )
	
	, q(0,3,line)	
	, delivery_city_state_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	nearest( generic_hook(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ], tab ] )

	, generic_item( [ delivery_city, s1, tab ] )

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
	  
	, generic_horizontal_details( [ [ `Totale`, `netto`, `merce` ] ] )
	
	, generic_line( [ generic_item( [ total_net, d ] ) ] )

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
	  
	, q10( generic_horizontal_details( [ [ at_start, read_ahead( `Rif` ) ], customer_comments, s1 ] ) )
	 
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
i_line_rule_cut( line_header_line, [ `Articolo`, tab, `Vs`, `.` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Spese`, `bolli` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	line_invoice_line
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ dummy_item, s1, tab ] )
	  
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )
	
	, q10( generic_item_cut( [ line_percent_discount, d, tab ] ) )

	, generic_item_cut( [ line_net_amount, d, q10( tab ) ] )

	, generic_item( [ line_original_order_date, date, q10( tab ) ] )
	
	, thing(s1), newline

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
] ).