%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - ANDRITZ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( at_andritz, `20 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date
	
	, get_delivery_date

	, get_contacts
	
	, get_email
	
	, get_delivery_address

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, get_order_totals

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

	, buyer_registration_number( `AT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	, set( delivery_note_ref_no_failure )
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10015026` ) ]
		, suppliers_code_for_buyer( `10015026` )
	] )
	
	, sender_name( `Andritz AG` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ `Bestellnummer`, order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `Erstellungsdatum`, q0n(word) ], invoice_date, date ] )

] ).

%=======================================================================
i_rule( get_delivery_date, [
%=======================================================================	  
	  
	  q(0,40,line), generic_horizontal_details( [ [ or( [ `Leiferdatum`, `Liefertermin` ] ), `:`, q10( tab ) ], invoice_date, date ] )

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
	  
	, generic_horizontal_details( [ [ `Einkäufer`, dummy(s1), tab, `Fr`, `.` ], buyer_contact, s1 ] )
	
	, check( buyer_contact = Con )
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_email, [ 
%=======================================================================

	  q(0,15,line)
	  
	, generic_horizontal_details( [ [ `E`, `-`, `mail`, `:` ], buyer_email, s1 ] )
	
	, check( buyer_email = Email )
	, delivery_email( Email )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Lieferadresse`, `:` ], delivery_party, s1 ] )
	  
	, generic_horizontal_details( [ nearest( delivery_party(start), 10, 10 ), delivery_street, s1 ] )
	
	, delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,4), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_totals, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Gesamtbestellwert`, dummy(s1), tab, `EUR` ], 400, total_net, d ] )
	  
	, check( total_net = Net )
	, total_invoice( Net )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ or( [ [ `ANDRITZ`, `AG`, tab, `Legal` ], [ `Seite`, num(d) ] ] ) ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, qn0( 
		or( [ line_invoice_rule
			, line
		] )
	)
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, `Material` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Gesamtbestellwert` ] ).
%=======================================================================
i_line_rule_cut( line_bruttopreis_line, [ `Bruttopreis`, clear( get_descr ) ] ).
%=======================================================================
i_line_rule_cut( line_skip_line, [ peek_fails( `Gesamtpositionswert` ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_pos_line
	
	, set( get_descr )
	
	, q0n( 
		or( [ line_bruttopreis_line
			, line_item_line
			, line_descr_line
			, line_skip_line 
		] ) 
	)
	
	, line_total_line
	
	, clear( get_descr )
	, clear( got_descr )
	, clear( got_item )
	
] ).

%=======================================================================
i_line_rule_cut( line_pos_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, tab ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	, generic_item( [ line_quantity_uom_code, w, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [ test( get_descr ),
%=======================================================================

	peek_fails( `Liefertermin` )
	
	, or( [ [ peek_fails( test( got_descr ) ), generic_item( [ line_descr, s1, set( got_descr ) ] ) ]
	
		, [ test( got_descr ), append( line_descr(s1), ` `, `` ) ]
	] )
	
	, q01( [ tab, append( line_descr(s1), ` `, `` ) ] )
	
	, newline

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [ peek_fails( test( got_item ) ),
%=======================================================================

	peek_fails( `Liefertermin` )

	, qn1(
		or( [ `Art`
			, `.`
			, `No`
			, `Nr`
			, `HERSTELLER`
			, `ARTIKELNUMMER`
			, `:`
			, `Lief`
			, `Hilti`
			, `Lieferantenmaterial`
			, tab(50)
		] )
	), generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )
	, set( got_item )

] ).

%=======================================================================
i_line_rule_cut( line_total_line, [
%=======================================================================

	`Gesamtpositionswert`
	
	, qn0( anything ), tab
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).