%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE STRABAG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_strabag, `03 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ get_fixed_variables, anderung_rule ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( anderung_rule, [ 
%=======================================================================

	  or( [ [ q(0,5,line)
	  
			, generic_horizontal_details( [ read_ahead( `Änderung` ), dummy, s1 ] )
			
			, delivery_note_reference( `special_rule` )
			
		]
		
		, set( process_order )
		
	] )	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_suppliers_code_for_buyer

	, get_order_number
	
	, get_due_date

	, get_delivery_details

	, get_contacts
	
	, get_emails
	
	, get_faxes
	
	, get_ddis

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

	, get_invoice_lines
	
	, q10( [ test( line_needs_completing ), line_item( `Missing` ) ] )

] ):- grammar_set( process_order ).

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
	
	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [
%=======================================================================	  
	  
	  q(0,6,line)
	  
	, or( [ [ generic_horizontal_details( [ [ at_start, qn0(word) ], zip, [ begin, q(dec,4,5), end ]
	
			, check( i_user_check( pc_lookup, zip, SCFB ) ) ] )
			
		]
		
		, [ generic_horizontal_details( [ [ at_start, q0n(word) ], city, wf, check( i_user_check( pc_lookup, city, SCFB ) ) ] ) ]
		
	] )
	
	, suppliers_code_for_buyer( SCFB )
	
] ).

%=======================================================================
i_user_check( pc_lookup, Value_IN, SCFB )
%-----------------------------------------------------------------------
:-
%=======================================================================	  
	  
	string_to_lower( Value_IN, Value_L ),
	
	( pc_to_scfb_lookup( Value_L, _, SCFB_Test, SCFB_Live )
	
		;	pc_to_scfb_lookup( _, Value_L, SCFB_Test, SCFB_Live )		
	),
	
	( grammar_set( test_flag )
		->	SCFB = SCFB_Test
		
		;	SCFB = SCFB_Live
	)
.

pc_to_scfb_lookup( `44149`, `dortmund`, `10127464`, `10127464` ).
pc_to_scfb_lookup( `4003`, `münster`, `10128305`, `15344582` ).
pc_to_scfb_lookup( `52070`, `aachen`, `10312245`, `16732335` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `NR`, `.` ], order_number, s, [ `/`, generic_item( [ invoice_date, date ] ) ] ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Liefertermin`, `:` ], 300, due_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,15,line)
	  
	, generic_horizontal_details( [ [ `Unser`, `Zeichen`, or( [ [ q0n(word), or( [ `Herr`, `frau` ] ) ], word ] ) ], buyer_contact, s1 ] )
	
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_ddis, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Durchwahl` ], buyer_ddi_x, sf, `FAX` ] )
	  
	, check( string_string_replace( buyer_ddi_x, `+49`, `0`, DDI ) )
	
	, check( strip_string2_from_string1( DDI, `-`, DDI_2 ) )

	, buyer_ddi( DDI_2 )
	
	, delivery_ddi( DDI_2 )

] ).

%=======================================================================
i_rule( get_faxes, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Fax`, `.`, `:` ], buyer_fax_x, s1 ] )
	  
	, check( string_string_replace( buyer_fax_x, `+49`, `0`, Fax ) )
	
	, check( strip_string2_from_string1( Fax, `-`, Fax_2 ) )
	
	, buyer_fax( Fax_2 )
	
	, delivery_fax( Fax_2 )

] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `E`, `-`, `Mail` ], buyer_email, s1 ] )
	  
	, check( buyer_email = Email )
	
	, delivery_email( Email )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_header_line, [ `Lieferanschrift`, `/` ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q0n(line), delivery_header_line
	  
	, q10( firma_line )
	
	, delivery_thing( [ delivery_party ] )
	
	, delivery_thing( [ delivery_dept ] )
	
	, q10( delivery_thing( [ delivery_address_line ] ) )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_and_city_line
	
] ).


%=======================================================================
i_line_rule_cut( firma_line, [ `Firma`, newline ] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [ peek_fails( [ `Firma`, newline ] ), generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  or( [ [ q0n(line), read_ahead( generic_horizontal_details( [ [ `Gesamtpositionsnettowert`, tab, `EUR` ], 300, total_net, d, newline ] ) )
	  
			, check( total_net = Net )
	
			, total_invoice( Net )
			
		]
		
		, [ set( no_totals )
		
			, total_net( `0` )
	
			, total_invoice( `0` )
			
		]
		
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, qn0( [ peek_fails( line_end_line )

		  , or( [ 
		
			  complete_previous_line_rule
			  
			, line_invoice_rule
			
			, line_defect_line

			, line

		] )

	] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ `Gesamtpositionsnettowert`
	
		, `Rechnungsanschrift`
		
		, `Postanschrift`
		
		, [ `Strabag`, `Property` ]
		
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
	, trace( [ `End line` ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_defect_line, [ num(f( [ q(dec,5,5) ] ) ), tab, force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  or( [ [ test( line_needs_completing ), line_item( `Missing` ), clear( line_needs_completing ) ]
	  
		, peek_fails( test( line_needs_completing ) )
		
	] )
	
	, line_invoice_line
	  
	, q0n( line_descr_line )
	
	, or( [ line_item_line
	
		, [ or( [ peek_ahead( line_defect_line ), delivery_header_line, peek_ahead( line_end_line ) ] ), set( line_needs_completing ) ] 
		
	] )
	
	, with( invoice, due_date, Due )
	
	, line_original_order_date( Due )
	
	, or( [ test( line_needs_completing ), clear( got_descr ) ] )

] ).

%=
%=======================================================================
i_rule_cut( complete_previous_line_rule, [
%=======================================================================

	  test( line_needs_completing )
	  
	, q0n( line_descr_line )
	
	, or( [ line_item_line
	
		, [ or( [ peek_ahead( line_defect_line ), delivery_header_line, peek_ahead( line_end_line ) ] ) ] 
		
	] )
	
	, clear( got_descr )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )

	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, w ] )

	, or( [ [ tab, generic_item( [ line_unit_amount, d, [ q10( [ `/`, num(d) ] ), tab ] ] )
	
			, generic_item( [ line_net_amount, d, newline ] )
	
		]
		
		, newline
		
	] )
	
	, q10( [ test( no_totals )
	
		, line_net_amount( `0` )
	
	] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	  or( [ [ peek_fails( test( got_descr ) )
	  
			, generic_item( [ line_descr, s1, [ q01( [ tab, append( line_descr(s1), ` `, `` ) ] ), newline ] ] )
			
			, set( got_descr )
			
		]
		
		, [ test( got_descr )
		
			, append( line_descr(s1), ` `, `` ), q01( [ tab, append( line_descr(s1), ` `, `` ) ] ), newline 
			
		]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  or( [ [ `Ihre`, `Materialnummer` ]
	  
		, [ `Hilti`, q0n(word) ]
	  
		, [ q10( or( [ [ peek_fails( test( got_descr ) ), line_descr(sf) ]
		
					, [ test( got_descr ), append( line_descr(sf), ` `, `` ) ]
			
				] )
			
			)
			
			, qn1(
				or( [ 
					`Hilti`
					, `Artikelnummer`
					, `BestNr`
					, `.`
					, `:`
					, `Art`
					, `Nr`
					, `,`
					, `-`
				
				] )
			)
			
		]
		
		, [ `Art`, q10( `.` ), `Nr`, q10( `.` ) ]
		
		, [ `Artikel`, `-`, `Nr`, q10( `.` ), q10( tab ) ]

	] )

	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	
	, clear( line_needs_completing )

] ).
