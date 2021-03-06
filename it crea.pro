%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT CREA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ir_crea, `10 April 2015` ).

i_pdf_parameter( same_line, 8 ).

i_date_format( _ ).
i_format_postcode( X, X ).
i_op_param( xml_transform( delivery_street, In ), _, _, _, Out )
:-
	string_string_replace( In, `,`, ` `, Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date
	
	, get_contact_depts

	, get_contacts
	
	, get_delivery_address
	
	, get_customer_comments
	
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
	  [ test(test_flag), suppliers_code_for_buyer( `13070440` ) ]    %TEST
	    , suppliers_code_for_buyer( `13070440` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `CREA SPA` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMAIL ADDRESSES + TWEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_depts, [
%=======================================================================

	  buyer_contact( Con )
	, delivery_contact( Con )
	, trace( [ `Contacts`, Con ] )
	
] )
:-

	  i_mail( text, Clutter )
	  
%	, trace( `started` )

	, q_sys_sub_string( Clutter, Domain_Start, Domain_Length, `@creaspa.it` )
	
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
	
	, contact_lookup( Con, Email )
	
	, trace( `finished prologue-y bit` )
	
	, !
	
.

%=======================================================================
i_rule( get_contacts, [
%=======================================================================

	  buyer_contact( Con )
	, delivery_contact( Con )
	, trace( [ `Contacts`, Con ] )
	
] )
:-

	  i_mail( text, Clutter )
	  
%	, trace( `started` )

	, q_sys_sub_string( Clutter, Domain_Start, Domain_Length, `@creaspa.it` )
	
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

	, contact_lookup( Con, Email )
	
	, trace( `finished prologue-y bit` )
	
	, !
.

contact_lookup( `PAOLO BONALUMI`, `creafirenze@creaspa.it` ).
contact_lookup( `STEFANIA BOSISIO`, `amministrazione@creaspa.it` ).
contact_lookup( `CLAUDIO BRESOLIN`, `claudio.bresolin@creaspa.it` ).
contact_lookup( `FRANCO BRESOLIN`, `franco.bresolin@creaspa.it` ).
contact_lookup( `IGINO BRESOLIN`, `creaspa@creaspa.it` ).
contact_lookup( `c/o sede Firenze OCCHINO`, `creafirenze@creaspa.it` ).
contact_lookup( `GIUSEPPE PITINGOLO`, `ufficioacquisti@creaspa.it` ).
contact_lookup( `DOMENICO RICCIO`, `domenico.riccio@creaspa.it` ).
contact_lookup( `PIETRO RIVA`, `ufficiotecnico@creaspa.it` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line), generic_vertical_details( [ [ `Numero`, `documento` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,20,line), generic_vertical_details( [ [ `Data`, `documento` ], `Data`, end, invoice_date, date ] )
	
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
	, generic_horizontal_details( [ [ `Consegnare`, `a`, `:` ] ] )
	
	, q(0,3,line)
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 30 ), delivery_party, s1 ] )
	
	, q(0,3,line)
	, generic_horizontal_details( [ nearest( generic_hook(start), 10, 30 ), delivery_street, s1 ] )
	
	, q(0,3,line)	
	, delivery_city_state_postcode_line

] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================

	nearest( generic_hook(start), 10, 30 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ], `-` ] )

	, generic_item( [ delivery_city, sf, `(` ] )

	, generic_item( [ delivery_state, [ begin, q(alpha,2,2), end ] ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMENTS AND INSTRUCTIONS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	q(0,30,line), generic_vertical_details( [ [ `Commessa`, `CREA` ], `Commessa`, start, 50, 20, customer_comments, s1 ] )
	
] ).

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	q0n(line), generic_horizontal_details( [ [ at_start, read_ahead( dummy ), check( dummy(font) = 3 ) ], shipping_instructions, s1 ] )
	
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
	  
	, generic_horizontal_details( [ [ `Totale`, `merce` ], 300, total_net, d ] )

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

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Riga`, q10( tab ), `Codice` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `I`, `Materiali` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	line_invoice_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )
	  
	, generic_item( [ line_item, [ begin, q(dec,4,10), end, q(alpha("HILT"),0,5) ], tab ] )
	
	, generic_item_cut( [ line_descr, s, [ q10( tab ), check( line_descr(end) < -150 ) ] ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, tab ] )
	
	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )

	, generic_item_cut( [ line_net_amount, d, q10( tab ) ] )
	
	, tax(s1), tab

	, generic_item( [ line_original_order_date, date, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
] ).