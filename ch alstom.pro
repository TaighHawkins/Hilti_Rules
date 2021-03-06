%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CH ALSTOM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ch_alstom, `28 November 2013` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_buyer_contact
	
	, get_buyer_ddi

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

	  buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CH-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10402444` ) ]    %TEST
	    , suppliers_code_for_buyer( `10479364` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10402444` ) ]    %TEST
	    , delivery_note_number( `10635919` )                      %PROD
	]) ]
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * DELIVERY LOCATION * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,10,line), horizontal_details_line( [ [ `Bestellung`, `NR`, `.` ], order_number, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,20,line), horizontal_details_line( [ [ `Besteller`, `/`, `In`, `:`, tab, word ], buyer_contact, s1, tab ] )
	 
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,5,line), horizontal_details_line( [ [ `Datum` ], 200, invoice_date, date, gen_eof ] )
	  
] ).

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line)
	  
	, read_ahead( horizontal_details_line( [ [ `Bestellwert`, `total`, `netto`, `exkl`, `.`, `MWSt` ], 500, total_net, d, newline ] ) )
	  
	, horizontal_details_line( [ [ `Bestellwert`, `total`, `netto`, `exkl`, `.`, `MWSt` ], 500, total_invoice, d, newline ] )
	  
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER DDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,20,line), buyer_ddi_line
	  
] ).

%=======================================================================
i_line_rule( buyer_ddi_line, [ 
%=======================================================================

	  `Besteller`, q0n(anything), `Tel`
	  
	, set(regexp_cross_word_boundaries)
	
	, buyer_ddi(f( [ begin, q([dec,other_skip("/")],8,13), end ] ) )
	
	, clear(regexp_cross_word_boundaries)
	
	, trace( [ `buyer ddi`, buyer_ddi ] )
	  
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

	, qn0( [ peek_fails(line_end_line)

		, or( [  line_invoice_rule
			
				, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_firmenrabatt_line, [ `Firmenrabatt`, trace( [ `firmenrabatt line` ] ) ] ).
%=======================================================================
i_line_rule_cut( line_header_line, [ `Artikelbezeichnung`, tab, `Termin` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	  `Für`, `die`, `Ausführung`

	  
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line_one
	  
	, line_invoice_line_two
	
	, q10( line_firmenrabatt_line )
	
	, horizontal_details_line( [ [ `Ihre`, `Artikelbezeichnung` ], line_item, sf, one_of_these_things_rule ] )

] ).

%=======================================================================
i_rule_cut( one_of_these_things_rule, [
%=======================================================================

	  or( [ `/`, `(`, tab, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_one, [
%=======================================================================

	  invoice_item( [ line_order_line_number, d, none ] )
	  
	, invoice_item( [ line_item_for_buyer, s1, tab ] )
	
	, invoice_item( [ line_original_order_date, date, tab ] )
	
	, invoice_item( [ line_quantity, d, `q10`, tab ] )
	
	, invoice_item( [ line_quantity_uom_code, w, tab ] )
	
	, invoice_item( [ line_unit_amount_x, d, tab ] )
	
	, invoice_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_two, [
%=======================================================================

	  invoice_item( [ line_descr, s1, tab ] )
	
	, invoice_item( [ dummy_uom, s1, newline ] )
	
] ).



%=======================================================================
i_rule_cut( invoice_item( [ VARIABLE, PARAMETER, SPACING ] ), [ invoice_item_rule( [ VARIABLE, PARAMETER, `not`, SPACING ] ) ] ).
%=======================================================================
i_rule_cut( invoice_item( [ VARIABLE, PARAMETER, OPTIONAL, SPACING ] ), [ invoice_item_rule( [ VARIABLE, PARAMETER, OPTIONAL, SPACING ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( invoice_item_rule( [ VARIABLE, PARAMETER, OPTIONAL, SPACING ] ), [ 
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
