%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HEIDELBERGER BETON GMBH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_heidelbergercement, `02 June 2015` ).

i_date_format( _ ).
i_format_postcode( X,X ).

i_pdf_paramater( x_tolerance_100, 100 ).

i_user_field( invoice, buyer_ddiy, `Buyer DDI` ).
i_user_field( invoice, buyer_faxy, `Buyer DDI` ).
i_user_field( invoice, buyers_code_for_buyery, `Buyers code for buyer` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, gen_capture( [ [ `Bestell`, `-`, `Nr`, `:`, tab ], order_number, s1, newline ] )
	, gen_capture( [ [ `Datum`,`:`, tab ], invoice_date, date, newline ] )
	, gen_capture( [ [ `Lieferdatum`,`:`, tab ], delivery_date, date, newline ] )
	
	, gen_capture( [ [ `Telefon`, `:`, tab ], buyer_ddiy, s1, newline ] )
	, q10( gen_capture( [ [ `Telefax`, `:`, tab ], buyer_faxy, s1, newline ] ) )
	
	, gen_vert_capture( [ 
	
		or( [
		
			[ `Umsatzsteuer`, `Identnummer`, `:` ]
			
			, [ `Steuernummer`, `:` ]
			
			, [ `USt`, `-`, `IdNr`, `.`, `:` ]
			
		] )
		
		, buyers_code_for_buyery, s1, gen_eof 
		
	] )

	, replace_faxy_chars
	
	, replace_ddiy_chars
	
	, replace_bcfb_chars
	
	, get_email_address
	
	, get_delivery_location
		
	, set(reverse_punctuation_in_numbers)
	
	, get_invoice_lines
	
	, get_invoice_totals
	
	, clear(reverse_punctuation_in_numbers)
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%
	
	, sender_name( `Heidelberger Beton GmbH` )
	
	, set( no_pc_cleanup )
	, set( no_scfb )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET EMAIL ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_email_address, [ 
%=======================================================================
	
	q0n(line)
	
	, or( [ 
	
		get_email_address_line
		
		, get_email_address_line(3, 0,500) 
		
	] )
	
] ).

%=======================================================================
i_line_rule( get_email_address_line, [ 
%=======================================================================
	
	`e`, `-`, `mail`, `:`
	
	, read_ahead( [ generic_item( [ buyer_email, s1, newline ] ) ] )
	
	, buyer_contactx(sf)
	
	, `@`
	
	, dummy(s1), newline
	
	, check( i_user_check( gen_string_to_upper, buyer_contactx, Buyer  ) )
	
	, check( string_string_replace( Buyer, `.`, ` `, Buyer1 ) )
	
	, buyer_contact( Buyer1 )
	
	, delivery_contact( Buyer1 )
	
	, with( invoice, buyer_email, Email )
	
	, delivery_email( Email )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE CHARS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( replace_faxy_chars, [ 
%=======================================================================
	
	with(invoice, buyer_faxy, FAX)
	, check( strip_string2_from_string1( FAX, `-/`, FAX1 ) )
	, check( string_string_replace( FAX1, `+`, `0`, FAX2 ) )
	, buyer_fax( FAX2 ), delivery_fax( FAX2 ) 

] ). 

%=======================================================================
i_rule( replace_ddiy_chars, [ 
%=======================================================================

	with(invoice, buyer_ddiy, DDI)
	, check( strip_string2_from_string1( DDI, `-/`, DDI1 ) )	
	, check( string_string_replace( DDI1, `+`, `0`, DDI2 ) )
	, buyer_ddi( DDI2 ), delivery_ddi( DDI2 )

] ). 

%=======================================================================
i_rule( replace_bcfb_chars, [ 
%=======================================================================

	with(invoice, buyers_code_for_buyery, BCode)
	, check( strip_string2_from_string1( BCode, `\\/!-"£$%^&*()_-+=}]{['@#~,.?`, BCode1 ) )
	, trace( [ BCode1 ] )
	, check( strcat_list( [ `DEHC`, BCode1 ], BCode2 ) )
	, buyers_code_for_buyer(BCode2)
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	q0n(line)

	, delivery_party_line
	
	, trace( [ `Here` ] )
	
	, q10( delivery_dept_line )
	
	, trace( [ `Here1` ] )
	
	, delivery_street_line
	
	, trace( [ `Here2` ] )
	
	, delivery_postcode_line
	
	, q01( shipping_information_line )

] ).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	q0n(anything)
	
	, or( [

		[ `Lieferanschrift`, `:` ]
		
		, [ `Anlieferung`,  `Werk`, `:` ] 
		
	] )

	, tab, read_ahead( [ generic_item( [ delivery_party, s1, newline ] ) ] )
	
	, header(s1), newline 
	
] ).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ delivery_dept, s1, newline ] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ delivery_street, s1, newline ] )
	
] ).


%=======================================================================
i_line_rule( delivery_postcode_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 )
	
	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
	
	, generic_item( [ delivery_city, s1 ] ), newline
	
] ).

%=======================================================================
i_line_rule( shipping_information_line, [ 
%=======================================================================

	nearest_word( header(start), 20,20 ), generic_item( [ shipping_information, s1, newline ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
i_section_end( get_invoice_lines, line_end_section_line ).
i_line_rule_cut( line_end_section_line, [
%=======================================================================
	  
	`Geschäftsführer`, `:`, tab, `Walhalla`, `Kalk`, `GmbH`, `&`, `Co`, `.`, `KG`, tab

] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ 
		
			get_line_invoice_rule

			,line
			])

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Pos`, `.`, tab, `Bezeichnung`, tab, `Menge`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================
	
	`Gesamt`, `ohne`, `mwst` 
		
] ).

%=======================================================================
i_rule_cut( get_line_invoice_rule, [
%=======================================================================
	
	line_values_line
	
	, q10( underscore_line )
	
	, q01( line_description_line )
	
	, q10( underscore_line )

	, line_item_line
	
	, q10( underscore_line )

	, q10( continuation_line )
	
] ).

%=======================================================================	
i_line_rule_cut( line_values_line, [
%=======================================================================
	
	generic_item( [ line_order_line_number, d, q10(tab) ] )
	
	, q10( generic_item( [ line_item_for_buyer, s1, tab ] ) )

	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ dummy, s1, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )
	
	, with(invoice, delivery_date, Date )
	
	, line_original_order_date( Date ) 
	

] ).

%=======================================================================
i_line_rule_cut( line_description_line, [
%=======================================================================
		
	generic_item( [ line_descr, s1 ] ), q01( [ tab, dummy(s1) ] )
	
	, newline
	
	, set( got_descr )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================
	
	or( [
			
		[ `Art`, `.`, `Nr`, `.` ]
			
		, [ `Art`, `.`, `Nr`, `.`, `:` ]
			
		, [ `Nr`, `.` ]
			
		, [ `Art`, `Nr`, `.` ]
			
		, [ `Art`, `Nr`, `.`, `:` ]
		
		, [ `Ihre`, `Materialnummer`, `:` ]	
		
		, [ `Ihre`, `Materialnummer` ]
			
		, [ `Artikelnummer`, `:` ]
		
		, [ `Artikelnummer` ]
			
		, [ `Artikelnr`, `:` ]
			
		, [ `BestNr`, `:` ]
			
		, [ `Art`, `.` ]
			
		, [ `Art`, `:` ]
		
		, [ `Anr`, `:` ]
			
		, [ `Artnr`, `.`, `:` ]
			
		, [ `Art`, `.`, `nr`, `.`, `Lieferant` ]
		
		, [ `HerstellerteileNr`, `:` ]
		
	] )
	
	, generic_item( [ line_item, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( continuation_line, [
%=======================================================================
	
	peek_fails( [ 
	
		or( [
			
			[ `Art`, `.`, `Nr`, `.` ]
			
			, [ `Art`, `.`, `Nr`, `.`, `:` ]
			
			, [ `Nr`, `.` ]
			
			, [ `Art`, `Nr`, `.` ]
			
			, [ `Art`, `Nr`, `.`, `:` ]
			
			, [ `Ihre`, `Materialnummer` ]
			
			, [ `Ihre`, `Materialnummer`, `:` ]
			
			, [ `Artikelnummer` ]
			
			, [ `Artikelnummer`, `:` ]
			
			, [ `Artikelnr`, `:` ]
			
			, [ `BestNr`, `:` ]
			
			, [ `Art`, `.` ]
			
			, [ `Art`, `:` ]
			
			, [ `Anr`, `:` ]
			
			, [ `Artnr`, `.`, `:` ]
			
			, [ `Art`, `.`, `nr`, `.`, `Lieferant` ]
			
			, [ `HerstellerteileNr`, `:` ]
		
			, [ `-`, `-`, `-`, `-`, `-` ]
			
			, [ `_`, `_`, `_`, `_`, `_`, `_` ]
		
		] )
		
	] )
	
	, or( [ 
	
		[ test( got_descr ), append( line_descr(s1), ` - `, `` ), clear( got_descr ) ]
		
		, [ line_descr(s1) ] 
		
	] ), newline 

] ).

%=======================================================================
i_line_rule_cut( underscore_line, [
%=======================================================================
		
	`_`, `_`, `_`

] ).		
	
%=======================================================================
i_rule_cut( get_invoice_totals, [
%=======================================================================
		
	gen_capture( [ [ `Gesamt`, `ohne`, `Mwst`, `EUR`, tab ], total_net, d, newline ] )
			
	, with(invoice, total_net, Net)
	, total_invoice(Net)

] ).






