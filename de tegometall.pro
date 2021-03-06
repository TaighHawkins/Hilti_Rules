%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE TEGOMETALL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_tegometall, `19 August 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_vert_capture( [ [ `Bestellnummer`, `/`, `Datum`, newline ], order_number, s1 ] )
	, gen_vert_capture( [ [ `Bestellnummer`, `/`, `Datum`, newline ], order_number_x, sf, [ `/`, generic_item( [ invoice_date, date, newline ] ) ] ] )
	
	, get_contact_details
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, gen_capture( [ [ `Gesamtnettowert`, `ohne`, `Mwst`, `EUR` ], 300, total_net, d, newline ] )
	, gen_capture( [ [ `Gesamtnettowert`, `ohne`, `Mwst`, `EUR` ], 300, total_invoice, d, newline ] )

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

	, [ or([
	  [ test(test_flag), suppliers_code_for_bill_to( `10126495` ) ]    %TEST
	    , suppliers_code_for_bill_to( `10124151` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Tegometall International Sales GmbH` )

	, suppliers_code_for_buyer( `10128035` )
	
	, delivery_note_reference( `DETEGOSAULDORF` )
	, set( delivery_note_ref_no_failure )
	, set( leave_spaces_in_order_number )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_details, [
%=======================================================================	  

	  q0n(line)
	
	, generic_vertical_details( [ [ `AnsprechpartnerIn`, `/`, `Telefon`, newline ], contact, s1, newline ] )
	
	, check( i_user_check( contact_cleanup, contact, Contact ) )
	, buyer_contact( Contact )
	, delivery_contact( Contact )
	
	, generic_vertical_details( [ [ `Unsere`, `Faxnummer`, newline ], buyer_fax, s1, newline ] )
	
	, check( buyer_fax = Fax )
	, delivery_fax( Fax )
	
] ).

%-----------------------------------------------------------------------
i_user_check( contact_cleanup, Contact_in, Contact_out )
%-----------------------------------------------------------------------
:-
	string_to_upper( Contact_in, CONTACT ),
	sys_string_split( CONTACT, ` `, [ LAST, FIRST ] ),
	strcat_list( [ FIRST, ` `, LAST ], Contact_out ),
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, qn0( [ peek_fails( line_end_line )

		, or( [
		
			generic_line( [ [ `_`, `_`, `_`, `_`, `_` ] ] )
			
			, line_invoice_rule

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Bestellmenge`, tab, `Einheit`, tab, `Preis`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  or( [
	
		[ `Gesamtnettowert`, `ohne`, `Mwst` ]
		
		, [ `International`, `Sales`, `GmbH` ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_1
	
	, line_2
	
	, generic_horizontal_details( [ [ at_start, `Liefertermin` ], line_original_order_date, date, newline ] )
	
	, q10( check_for_double_rule )
	
	, q01(line)
	
	, generic_horizontal_details( [ [ `HILTI`, `-`, `ART`, `.`, q10( [ `NR`, `.` ] ), q10(`:`) ], line_item, [ begin, q(dec,4,10), end ] ] )
	
	, q10( [ test( need_amounts )
	
		, q01(line)
		, line_net_amount_line
		
	] )
	
	, count_rule
	
	, q10( [ test( double_line )
		
		, q01(line)
		, generic_horizontal_details( [ at_start, line_descr, s1, newline ] )
		, generic_horizontal_details( [ [ `HILTI`, `-`, `ART`, `.`, `NR`, `.` ], line_item, [ begin, q(dec,4,10), end ] ] )
		
		, check( line_item_for_buyer = LIFB ), line_item_for_buyer( LIFB )
		, check( line_quantity = QTY ), line_quantity( QTY )
		, check( line_quantity_uom_code = UOM ), line_quantity_uom_code( UOM )
		, check( line_original_order_date = Date ), line_original_order_date( Date )
		
		, count_rule
	
	] )
	
	, clear( double_line )
	, clear( need_amounts )
	
] ).

%=======================================================================
i_line_rule_cut( line_1, [
%=======================================================================

	  generic_no( [ line_order_line_number_x, d ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_descr, s1, [ q01( [ tab, append( line_descr(s1), ` `, `` ) ] ), newline ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_2, [
%=======================================================================

	  generic_no( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1 ] )
	
	, or( [
	
		[ tab, generic_no( [ line_unit_amount_x, d, [ q10( [ `/`, per(d) ] ), tab ] ] )
			, generic_no( [ line_net_amount, d, newline ] )
		]
		
		, set( need_amounts )
		
	] )
	
] ).

%=======================================================================
i_rule_cut( check_for_double_rule, [
%=======================================================================

	q(2,2,
		[ q0n( [ line
			, peek_fails( 
				or( [ generic_line( [ [ num(f( [ q(dec,5,5) ] ) ), trace( [ `Double check failed` ] ) ] ] )
					, line_end_line
				] )
			)
		] )
	
			, generic_line( [ [ `Hilti`, `-`, `Art` ] ] )
		]
	)
	
	, set( double_line )
	, trace( [ `Double line detected` ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_double_line, [
%=======================================================================

	  `Ihre`, `Materialnummer`
	
	, q10( [ q0n(word), `+`, set( double_line ) ] )

] ).

%=======================================================================
i_line_rule_cut( line_net_amount_line, [
%=======================================================================

	  `Nettowert`, tab
	
	, generic_no( [ line_unit_amount_x, d, q10(tab) ] )
	
	, `EUR`, tab
	
	, generic_item( [ per, s1, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).