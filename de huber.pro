%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE HUBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_huber, `27 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_totals

	, missing_totals_rule
		
	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_delivery_dept
	
	, get_contacts
	
	, get_emails
	
	, get_faxes
	
	, get_ddis
	
	, get_customer_comments
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10267671` ) ]    %TEST
	    , suppliers_code_for_buyer( `10267671` )                      %PROD
	]) ]

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `BESTELLUNG`, `-`, `NR`, `.`, `:` ], 100, order_number, s1, tab ] )
	
] ).


%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Bestelldatum`, `:` ], invoice_date, date, newline ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,15,line), buyer_contact_line
	  
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )

] ).

%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	  q0n(anything), `Ansprechpartner`, `:`, tab
	  
	, surname(sf), `,`

	, buyer_contact(s1)
	
	, check( surname = Sur )
	
	, append( buyer_contact( Sur ), ` `, `` )
	
	, trace( [ `buyer contact`, buyer_contact ] )

] ).

%=======================================================================
i_rule( get_ddis, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Telefon`, `:` ], buyer_ddi_x, s1, newline ] )
	  
	, check( string_string_replace( buyer_ddi_x, "+49", "0", DDI ) )
	
	, check( strip_string2_from_string1( DDI, `-`, DDI_2 ) )

	, buyer_ddi( DDI_2 )
	
	, delivery_ddi( DDI_2 )

] ).

%=======================================================================
i_rule( get_faxes, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Fax`, `:` ], 150, buyer_fax_x, s1, newline ] )
	  
	, check( string_string_replace( buyer_fax_x, "+49", "0", Fax ) )
	
	, check( strip_string2_from_string1( Fax, `-`, Fax_2 ) )
	
	, buyer_fax( Fax_2 )
	
	, delivery_fax( Fax_2 )

] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `E`, `-`, `Mail`, `:` ], 100, buyer_email, s1, newline ] )
	  
	, check( buyer_email = Email )
	
	, delivery_email( Email )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Lieferanten`, `-`, `Nr`, `.`, `:` ], 150, customer_comments, s1, gen_eof ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_header_line, [ `Firma`, tab, read_ahead( `Lieferadresse` ), delivery_hook ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q(0,2,line), delivery_header_line
	  
	, delivery_thing( [ delivery_party ] )
	
	, q10( gen_line_nothing_here( [ delivery_hook(start), 10, 10 ] ) )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_and_city_line
	
] ).


%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [
%=======================================================================

	  q10( [ dummy(s1), tab ] )
	  
	, Read_Variable
	
	, check( Check_Var > 0 )

	, trace( [ String, Variable ] )

] ):-

	  Read_Variable =.. [ Variable, s1 ]
	, Check_Var =.. [ Variable, start ]
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  q10( [ dummy(s1), tab ] )
	  
	, delivery_postcode(f( [ begin, q(dec,5,5), end ] ) )
	
	, check( delivery_postcode(start) > 0 )
	
	, generic_item( [ delivery_city, s1, newline ] )

] ).

%=======================================================================
i_rule( get_delivery_dept, [
%=======================================================================
	  
	  q(0,40,line), generic_horizontal_details( [ [ `Anlieferort`, `:` ], 100, delivery_dept, s1, newline ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), q01( set( reverse_punctuation_in_numbers ) ), read_ahead( generic_horizontal_details( [ [ `Gesamtnetto`, tab, `EUR` ], 200, total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `Gesamtnetto`, tab, `EUR` ], 200, total_invoice, d, newline ] )

] ).

%=======================================================================
i_rule( missing_totals_rule, [
%=======================================================================

	  without( total_net ), q0n(line), q01( set( reverse_punctuation_in_numbers ) )
	  
	, read_ahead( generic_horizontal_details( [ [ `Gesamtbrutto`, tab, `EUR` ], 200, total_net, d, newline ] ) )
	  
	, generic_horizontal_details( [ [ `Gesamtbrutto`, tab, `EUR` ], 200, total_invoice, d, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_section_end_line ).
%=======================================================================
i_line_rule( line_section_end_line, [ `Adresse`, `/`, `address` ] ).
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
i_line_rule_cut( line_header_line, [ `Bezeichnung`, tab, `Steuer` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ `Gesamtnetto`, `Gesamtbrutto` ] ), tab ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, line_first_descr_line
	
	, or( [ [ q0n( line_continuation_line )
	
			, line_item_line
			
		]
		
		, [ read_ahead( [ q0n(line), peek_fails( line_original_order_date_line )
		
				, in_descr_line_item_line
			
			] )
			
			, q0n( line_continuation_line )
			
		]
		
		, [ line_item( `Missing` ), q0n( line_continuation_line ) ]
		
	] )
	
	, line_original_order_date_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, [ q10( [ `/`, num(d) ] ), tab ] ] )

	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, w, q10( tab )] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, q01( generic_item( [ something_here, w, tab ] ) )

	, generic_item( [ p_einh, s1, tab ] )
	
	, generic_item( [ ust, s1, tab ] )
	
	, generic_item( [ line_unit_amount_x, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_first_descr_line, [
%=======================================================================

	  generic_item( [ line_descr, s1, tab ] )
	  
	, q01( [ append( line_descr(s1), ` `, `` ), tab ] )
	  
	, q10( generic_item( [ some_uom, s1, tab ] ) )
	
	, generic_item( [ some_tax, d ] )
	
	, `%`, newline

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	  read_ahead( dummy(s1) )
	  
	, check( dummy(start) > -260 )
	
	, check( dummy(end) < 40 )
	
	, append( line_descr(s1), ` `, `` )
	
	, q01( [ tab, read_ahead( other_dummy(s1) )
	
		, check( other_dummy(end) < 40 )
		
		, append( line_descr(s1), ` `, `` )
		
	] )

	, q01( [ q10( tab ), odd_dummy(s1)
	
		, check( odd_dummy(start) > 40 )
		
		, check( odd_dummy(end) < 150 )
		
	] ), newline

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  q0n( [ or( [  `Artikel`, `ART`, `.`, `-` ] ) ] )
	  
	, `Nr`, qn1( [ or( [ `.`, `:` ] ) ] )
	
	, line_item(sf), q10( [ `/`, dummy(d) ] ), newline
	
	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( in_descr_line_item_line, [
%=======================================================================

	  q0n(word)

	, or( [ `Nr`, `Art` ] ), qn1( [ or( [ `.`, `:` ] ) ] )
	
	, line_item(f( [ begin, q(dec,4,10), end ] ) ), q10( [ `/`, dummy(d) ] ), newline
	
	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( line_original_order_date_line, [
%=======================================================================

	  `Anlieferdatum`, `:`, tab
	
	, generic_item( [ line_original_order_date, date, newline ] )

] ).