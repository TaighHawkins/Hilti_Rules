%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TOZZI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( tozzi, `20 November 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_suppliers_code_for_buyer
	
	, get_delivery_address

	, get_buyer_contact
	
	, get_buyer_email
	
	, get_buyer_ddi
	
	, get_buyer_fax

	, get_order_date
	
	, get_order_number

	, get_invoice_lines

	, get_totals
	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  set( reverse_punctuation_in_numbers )

	, buyer_party( `LS` )

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

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	  q0n(line), identity_line
	  
	, or( [ [ test( tozzi_sud ), tozzi_sud_scfb ]
	
			, [ test( tozzi_industry ), tozzie_industry_scfb ]
			
			, [ test( comart ), comart_scfb ]
			
			, [ test( tozzi_renewable ), tozzi_renewable_scfb ]
			
		] )
		
	, trace( [ `scfb`, suppliers_code_for_buyer ] )
	  
] ).

%=======================================================================
i_line_rule( identity_line, [ 
%=======================================================================

	  `Tutte`, tab
	  
	, or( [ [ q(0,3, word ), `TOZZI`, `SUD`, set( tozzi_sud ) ]
	
			, [ `TOZZI`, `INDUSTRIES`, `SRL`, set( tozzi_industry ) ]
			
			, [ `OF`, `.`, `RA`, `SRL`, set( comart ) ]
			
			, [ q(0,3,word), `TOZZI`, `RENEWABLE`, set( tozzi_renewable ) ]
			
		] )
	  
] ).

%=======================================================================
i_rule( tozzi_sud_scfb, [ 
%=======================================================================

	  or( [ [ test( test_flag ), suppliers_code_for_buyer( `10674425` ) ]
	  
			, suppliers_code_for_buyer( `13015571` )
			
		] )
	  
] ).

%=======================================================================
i_rule( tozzi_renewable_scfb, [ 
%=======================================================================

	  or( [ [ test( test_flag ), suppliers_code_for_buyer( `13028201` ) ]
	  
			, suppliers_code_for_buyer( `13028201` )
			
		] )
	  
] ).

%=======================================================================
i_rule( tozzie_industry_scfb, [ 
%=======================================================================

	  or( [ [ test( test_flag ), suppliers_code_for_buyer( `10658906` ) ]
	  
			, suppliers_code_for_buyer( `19933962` )
			
		] )
	  
] ).

%=======================================================================
i_rule( comart_scfb, [ 
%=======================================================================

	  or( [ [ test( test_flag ), suppliers_code_for_buyer( `10671792` ) ]
	  
			, suppliers_code_for_buyer( `15102917` )
			
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

	  q0n(line), delivery_party_dept_street_line
	  
	, delivery_postcode_city_location_line
	  
	  
] ).

%=======================================================================
i_line_rule( delivery_party_dept_street_line, [ 
%=======================================================================

	  `Tutte`, tab
	  
	, read_ahead( dummy(s1) )
	
	, trace( [ `dummy`, dummy ] )
	  
	, or( [ [ test( tozzi_sud ), count( 1 ) ]
	
			, [ test( tozzi_industry ), count( 1 ) ]
			
			, [ test( comart ), count( 2 ) ]
			
			, [ test( tozzi_renewable ), count( 1 ) ]
			
		] )
	
	, check( i_user_check( gen_same, count, COUNT ) )
		
	, delivery_party(w)
	
	, trace( [ `first delivery party` ] )
	
	, q( COUNT, COUNT, append( delivery_party(w), ` `, `` ) )
	
	, or( [ [ read_ahead( [ `C`, `/`, `O` ], set( cco ) ) ]
	
			, [ append( delivery_party(w), ` `, `` ) ]
			
		] )
	
	, trace( [ `delivery party`, delivery_party ] )
		
	, or( [ [ delivery_dept(sf)
	
			, read_ahead( `VIA` )
	
			, delivery_street(s1), newline
			
		]
		
		, [ test( cco )
		
			, delivery_dept(w)
			
			, q(2,2, append( delivery_dept(w), ` `, `` ) )
			
			, delivery_street(s1), newline
			
		]
		
		, delivery_street(s1), newline
		
	] )
	
	, trace( [ `delivery stuffs`, delivery_party, delivery_dept, delivery_street ] )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_city_location_line, [ 
%=======================================================================

	  delivery_postcode(f( [ begin, q(dec,5,5), end ] ) )
	  
	, delivery_city(sf)
	
	, delivery_state(f( [ begin, q(alpha,2,2), end ] ) )
	
	, trace( [ `other delivery stuffs`, delivery_postcode, delivery_city, delivery_state ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), horizontal_details_line( [ [ `Ordine`, `n`, `.` ], order_number, s1, tab ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,10,line), read_ahead( horizontal_details_line( [ [ `Gestore`, tab, word ], buyer_contact, s1, gen_eof ] ) )
	  
	, append_buyer_contact_line
	  
	, check( i_user_check( gen_same, buyer_contact, CONTACT ) )
	
	, delivery_contact( CONTACT )
	 
] ).

%=======================================================================
i_line_rule( append_buyer_contact_line, [ 
%=======================================================================

	  `Gestore`, tab, append( buyer_contact(w), ` `, `` )
	 
] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,10,line), horizontal_details_line( [ [ `email` ], buyer_email, s1, gen_eof ] )
	  
	, check( i_user_check( gen_same, buyer_email, EMAIL ) )
	
	, delivery_email( EMAIL )
	 
] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,10,line), horizontal_details_line( [ [ `Tel`, `.` ], buyer_ddi, s1, gen_eof ] )
	  
	, check( i_user_check( gen_same, buyer_ddi, DDI ) )
	
	, delivery_ddi( DDI )
	 
] ).

%=======================================================================
i_rule( get_buyer_fax, [ 
%=======================================================================

	  q(0,10,line), horizontal_details_line( [ [ `fax` ], buyer_fax, s1, gen_eof ] )
	  
	, check( i_user_check( gen_same, buyer_fax, FAX ) )
	
	, delivery_fax( FAX )
	 
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,5,line), horizontal_details_line( [ [ `del` ], 200, invoice_date, date, gen_eof ] )
	  
] ).

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line)
	  
	, read_ahead( horizontal_details_line( [ [ `IMPORTO`, `TOTALE`, `NETTO`, `DELLA`, q0n(anything) ], 200, total_net, d, newline ] ) )
	  
	, horizontal_details_line( [ [ `IMPORTO`, `TOTALE`, `NETTO`, `DELLA`, q0n(anything) ], 200, total_invoice, d, newline ] )
	  
] ).

%=======================================================================
i_line_rule( horizontal_details_line( [ SEARCH, VARIABLE, PARAMETER, AFTER ] ), [ horizontal_details( [ SEARCH, 100, VARIABLE, PARAMETER, AFTER ] ) ] ).
%=======================================================================
i_line_rule( horizontal_details_line( [ SEARCH, TAB_LENGTH, VARIABLE, PARAMETER, AFTER ] ), [ horizontal_details( [ SEARCH, TAB_LENGTH, VARIABLE, PARAMETER, AFTER ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( horizontal_details( [ SEARCH, TAB_LENGTH, VARIABLE, PARAMETER, AFTER ] ), [
%=======================================================================

	  q0n(anything)
	
	, SEARCH
	  
	, q10( or( [ `:`, `-`, `;`, `.` ] ) )
	
	, q10( tab( TAB_LENGTH ) )
	  
	, READ_VARIABLE
	
	, or( [ check( q_sys_member( AFTER_STRING, [ `none` ] ) )
	
			, AFTER
			
		] )
	
	, trace( [ VARIABLE_NAME, VARIABLE ] )

] )
:-

	  READ_VARIABLE=.. [ VARIABLE, PARAMETER ]
	
	, sys_string_atom( VARIABLE_NAME, VARIABLE )
	
	, sys_string_atom( AFTER_STRING, AFTER )
	
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

	, qn0( [ peek_fails(line_end_line)

		, or( [  line_invoice_rule
			
				, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `richiesta`, tab, `nr`, `stato`, tab, `unitario`, tab, `finale`,  newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `IMPORTO`, `TOTALE`, `NETTO`, `DELLA`, `FORNITURA` ] ).
%=======================================================================

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line_one
	  
	, or( [ [ test( item ), line_invoice_line_two ]
	
			, [ test( item ), line_item( `Missing` ) ]
			
			, peek_fails( test( item ) )
			
		] )
			
	, clear( item )


] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_one, [
%=======================================================================

	  invoice_item( [ line_original_order_date, date, tab ] )
	   
	, invoice_item( [ line_order_line_number, d, tab ] )
	  
	, invoice_item( [ line_item_for_buyer, s1, tab ] )
	
	, or( [ read_ahead( hilti_line_item_rule ), set( item ) ] )
	
	, invoice_item( [ line_descr, s1, tab ] )
	
	, q10( [ test( extra ), invoice_item( [ trash_item, s1, tab ] ) ] )
	
	, invoice_item( [ line_quantity_uom_code, w, tab ] )
		
	, invoice_item( [ line_quantity, d, tab ] )

	, invoice_item( [ line_unit_amount_x, d, tab ] )
		
	, q10( invoice_item( [ trash, s1, tab ] ) )
	
	, invoice_item( [ post_discount, s1, tab ] )

	, invoice_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_two, [
%=======================================================================

	  q10( [ trash(s1), tab ] )
	  
	, hilti_line_item_rule
	
] ).

%=======================================================================
i_rule( hilti_line_item_rule, [
%=======================================================================

	  q10( [ trash(s1), tab, set( extra ) ] )
	  
	, q0n(word), line_item(f( [ begin, q(dec,5,10), end ] ) )
	  
	, trace( [ `line item`, line_item ] )
	
] ).



%=======================================================================
i_rule( invoice_item( [ VARIABLE, PARAMETER, SPACING ] ), [ invoice_item_rule( [ VARIABLE, PARAMETER, `not`, SPACING ] ) ] ).
%=======================================================================
i_rule( invoice_item( [ VARIABLE, PARAMETER, OPTIONAL, SPACING ] ), [ invoice_item_rule( [ VARIABLE, PARAMETER, OPTIONAL, SPACING ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( invoice_item_rule( [ VARIABLE, PARAMETER, OPTIONAL, SPACING ] ), [ 
%=======================================================================

	  q10( [ check( q_sys_member( PARAMETER, [ `d` ] ) )
	  
				, q10( `$` )
	
		] )
		
	, READ_VARIABLE
			
	, q10( [ check( q_sys_member( VARIABLE_NAME, [ `line_descr` ] ) )
	  
			, check( q_sys_member( SPACING_STRING, [ `newline` ] ) )
			
			, q01( [ tab, READ_MORE_VARIABLE ] )
				
		] )
		
	, or( [ [ check( q_sys_member( SPACING_STRING, [ `none` ] ) ) ]
	
			, [ check( q_sys_sub_string( OPTIONAL, _, _, `not` ) )
	
				, SPACING
			
			]
			
			, [ check( q_sys_member( OPTIONAL, [ `q10` ] ) )
	
				, q10( SPACING )
			
			]
			
			, [ check( q_sys_member( OPTIONAL, [ `q01` ] ) )
	
				, q01( SPACING )
			
			]
		
		] )
	
	, trace( [ VARIABLE_NAME, VARIABLE ] )
	
] )
:-
	  READ_VARIABLE=.. [ VARIABLE, PARAMETER ]
	
	, READ_MORE_VARIABLE =.. [ append, READ_VARIABLE, ` `, `` ]
	
	, sys_string_atom( VARIABLE_NAME, VARIABLE )
	
	, sys_string_atom( SPACING_STRING, SPACING )
	
.
