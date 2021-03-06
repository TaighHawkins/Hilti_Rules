%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT STANDARD TECH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_standard_tech, `10 July 2015` ).

% i_pdf_parameter( same_line, 8 ).

i_date_format( _ ).
i_format_postcode( X, X ).
i_op_param( xml_transform( delivery_street, In ), _, _, _, Out )
:-
	string_string_replace( In, `,`, ` `, Out )
.

i_pdf_parameter( space, 4 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, get_invoice_date

	, gen_capture( [ [ `ORDINE`, `DI`, `ACQUISTO`, `N`, `°` ], order_number, s1, newline ] )
	, gen_capture( [ [ `Rif`, `.`, `Comm`, `.`, tab, `:` ], customer_comments, s1, gen_eof ] )
	
	, gen_vert_capture( [ [ `Resp`, `.`, `Acquisti` ], `Resp`, end, delivery_contact, s1, tab ] )
	
	, get_duplicate_details
	
	, get_invoice_lines
	
	, get_delivery_address
		
	, gen_capture( [ [ `IMPORTO`, `COMPLESSIVO`, `NETTO`, `-`, `SCONTO`, a(d), `%`, tab ], total_net, d, newline ] )
	, gen_capture( [ [ `IMPORTO`, `COMPLESSIVO`, `NETTO`, `-`, `SCONTO`, a(d), `%`, tab ], total_invoice, d, newline ] )
	
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
	
	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `13070440` ) ]    %TEST
	    , suppliers_code_for_buyer( `14401601` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Standard Tech Impianti s.r.l` )
	
	, set( delivery_note_ref_no_failure )
	
	, delivery_party(`STANDARD TECH IMPIANTI SRL`)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DUPLICATE DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_duplicate_details, [
%=======================================================================

	with(invoice, delivery_contact, Cont)
	
	, buyer_contact(Cont)
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ q0n(line), invoice_date_line ] ).
%=======================================================================
i_line_rule( invoice_date_line, [ 
%=======================================================================

	`Data`, tab, `:`, word, generic_item( [ invoice_date, d ] )
	
	, the_month(w)
	
	, check( i_user_check( convert_the_month, the_month, Num ) )
	
	, append( invoice_date( Num ), `/`, `/` )
	
	, append( invoice_date(d), ``, `` )
	
	, trace( [ `Invoice Date`, invoice_date ] )

] ).

%=======================================================================
i_user_check( convert_the_month, Month, Num )
%----------------------------------------
:-
%=======================================================================

	  string_to_lower( Month, Month_L )  
	, month_lookup( Month_L, Num )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	q0n(line)
	
	, generic_horizontal_details( [ [ `Resa` `:`, tab ], special_rule, s1, newline ] )
	
	, or( [ 
	
		[ check( special_rule = `f.co ns. sede` ), delivery_note_reference(`ITTECHMAGAZZINO`), trace( [ `Setting special rule` ] ) ]
		
		, [ delivery_dept_line
		
			, q10(delivery_street_line)
			
			, delivery_city_line
			
		] 
		
	] )
		
] ).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	nearest( special_rule(start), 10, 10 )
	
	, generic_item( [ delivery_dept, s ] )
	
	, q10( [
	
		or( [ `–`, `-` ] ), generic_item( [ delivery_street, s1 ] ), set(got_street)
		
	] )
	
	, newline
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	peek_fails( test( got_street ) )

	, nearest( special_rule(start), 10, 10 )
	
	, generic_item( [ delivery_street, s1, newline ] )
	
	, clear(got_street)
	
] ).

%=======================================================================
i_line_rule( delivery_city_line, [ 
%=======================================================================

	nearest( special_rule(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, d, or( [ `–`, `-` ] ) ] )
	
	, generic_item( [ delivery_city, s, `(` ] )
	
	, generic_item( [ delivery_state, s, [ `)`, newline ]  ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, q0n(

		or( [ line_invoice_line

			, line

		] )

	)

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	`Pos`, `.`, tab, `Descrizione`, tab, `Articolo`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `IMPORTO`, `COMPLESSIVO`, `NETTO`

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_item( [ line_order_line_number, d, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, q10( generic_item( [ line_item, d, tab ] ) )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, q10( generic_no( [ line_unit_amount, d, tab ] ) )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
	, with(invoice, invoice_date, InvDate)
	
	, line_original_order_date(InvDate)

] ).

month_lookup( `gennaio`, `01` ).
month_lookup( `genn`, `01` ).
month_lookup( `febbraio`, `02` ).
month_lookup( `febb`, `02` ).
month_lookup( `marzo`, `03` ).
month_lookup( `mar`, `03` ).
month_lookup( `aprile`, `04` ).
month_lookup( `apr`, `04` ).
month_lookup( `maggio`, `05` ).
month_lookup( `magg`, `05` ).
month_lookup( `giugno`, `06` ).
month_lookup( `luglio`, `07` ).
month_lookup( `agosto`, `08` ).
month_lookup( `ag`, `08` ).
month_lookup( `settembre`, `09` ).
month_lookup( `sett`, `09` ).
month_lookup( `ottobre`, `10` ).
month_lookup( `ott`, `10` ).
month_lookup( `novembre`, `11` ).
month_lookup( `nov`, `11` ).
month_lookup( `dicembre`, `12` ).
month_lookup( `dic`, `12` ).

















