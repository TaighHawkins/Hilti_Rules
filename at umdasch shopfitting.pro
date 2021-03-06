%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - UMDASCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( at_umdasch, `15 December 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_delivery_details
	
	, get_delivery_dept

	, get_buyer_ddi
	
	, get_buyer_contact

	, get_buyer_email

	, get_order_date

	, get_order_number

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_totals
	
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

	  without( buyer_party )
	
	, set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Umdasch Shopfitting GmbH` )
	, set( no_scfb )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,15,line)
	  
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), `EK`, `-`, `SB`, qn1( `.` ), `:` ], buyer_contact_x, s1, newline ] )
	
	, check( i_user_check( reverse_names, buyer_contact_x, Con ) )

	, buyer_contact( Con )
	, delivery_contact( Con )

] ).

%=======================================================================
i_user_check( reverse_names, NamesIn, NamesOut ):-
%=======================================================================

	sys_string_split( NamesIn, ` `, NamesList ),
	sys_reverse( NamesList, NamesRev ),
	wordcat( NamesRev, NamesOut )
.

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,15,line)
	  
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), `EK`, `-`, `SB`, `-`, `Tel`, qn1( `.` ), `:` ], buyer_ddi_x, s1, newline ] )
	
	, check( buyer_ddi_x = DDI_x )
	, check( string_string_replace( DDI_x, `+43`, `0`, DDI ) )
	, buyer_ddi( DDI )
	, delivery_ddi( DDI )

] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,20,line)
	  
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), `EK`, `-`, `SB`, `-`, `Email`, qn1( `.` ), `:` ], buyer_email, s1 ] )

	, check( buyer_email = Email )
	
	, delivery_email( Email )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_dept, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Abladestelle`, `:` ], 200, delivery_dept, s1 ] )

] ).

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ `Lieferadresse` ] )
	  
	, generic_horizontal_details( [ nearest( generic_hook(end), 10, 10 ), delivery_party, s1 ] )
	
	, q01( line ), generic_horizontal_details( [ nearest( delivery_party(start), 10, 10 ), delivery_street, s1 ] )
	
	, delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	  
	, generic_item( [ delivery_city, s1 ] )
	
	, check( delivery_postcode = PC )
	, check( strcat_list( [ `ATUMDA`, PC ], BCFB ) )
	, buyers_code_for_buyer( BCFB )
	, trace( [ `Buyers Code for Buyer`, BCFB ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q(0,10,line), generic_horizontal_details( [ [ or( [ at_start, tab ] ), `Nummer`, qn1( `.` ), `:` ], order_number, s1 ] )

] ).


%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q(0,20,line), generic_horizontal_details( [ [ `Datum`, qn1( `.` ), `:` ], invoice_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	  qn0(line), generic_vertical_details( [ [ `Nettobetrag`, tab, `MwSt` ], `Nettobetrag`, end, total_net, d ] )

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

	, q0n(

		or( [ line_invoice_rule

			, line

		] )

	), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `Artikelbezeichnung`, tab, `MEH` ] ), header(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ `Lieferkondition`, `:` ] 
	
		, [ dummy(w), check( not( dummy(page) = header(page) ) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, line_uom_line
	
	, q10( line_discount_line )
	
	, line_total_line
	
	, or( [ [ q(0,10, line_descr_line )
	
			, line_item_line
			
		]
		
		, [ qn0( line_descr_line )
		
			, line_item( `Missing` )
			
		]
		
	] )
	
	, clear( got_descr )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	  
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item( [ line_unit_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_uom_line, [
%=======================================================================

	  generic_item( [ descr, s1, tab ] )
	, check( descr = Descr )
	
	, or( [ [ peek_fails( test( got_descr ) ), line_descr( Descr ), set( got_descr ) ]
	
		, [ test( got_descr ), append( line_descr( Descr ), ` `, `` ) ]

	] )
	
	, generic_item( [ line_quantity_uom_code, s1 ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	  read_ahead( generic_item( [ descr, s1, newline ] ) )
	, check( descr = Descr )
	
	, or( [ [ peek_fails( test( got_descr ) ), line_descr( Descr ), set( got_descr ) ]
	
		, [ test( got_descr ), append( line_descr( Descr ), ` `, `` ) ]

	] )

] ).

%=======================================================================
i_line_rule_cut( line_discount_line, [ 
%=======================================================================

	q01( [ descr(s1), tab
		, check( descr = Descr )
	
		, or( [ [ peek_fails( test( got_descr ) ), line_descr( Descr ), set( got_descr ) ]
	
			, [ test( got_descr ), append( line_descr( Descr ), ` `, `` ) ]

		] )

	] ), `-`, generic_item( [ line_percent_discount, d, [ `%`, newline ] ] ) 
	
] ).

%=======================================================================
i_line_rule_cut( line_total_line, [
%=======================================================================

	q01( [ descr(s1), tab
		, check( descr = Descr )
	
		, or( [ [ peek_fails( test( got_descr ) ), line_descr( Descr ), set( got_descr ) ]
	
			, [ test( got_descr ), append( line_descr( Descr ), ` `, `` ) ]

		] )

	] ), generic_item( [ line_net_amount, d, [ q10( tab ), word,  newline ] ] ) 
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  qn0( or( [ `Ihre`, `Artikelnummer`, `:`, `.`
	  
			, `Art`, `Nr`, `Nummer`, `Artikel`
			
			, `artikelnr`, `Hilti`
		
		] )
		
	)
	
	, set( regexp_cross_word_boundaries )
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], check( line_item(end) < 0 ) ] )
	, clear( regexp_cross_word_boundaries )

] ).

