%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE FEE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_fee, `23 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_suppliers_code_for_buyer

	, get_order_number
	
	, get_order_date
	
	, get_delivery_date

	, get_contacts
	
	, get_delivery_details

	, get_emails
	
	, get_faxes
	
	, get_ddis
	
	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

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
	
	, sender_name( `F.EE Industrieautomation GmbH` )
	
	, set( reverse_punctuation_in_numbers )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [
%=======================================================================	  
  
	q(0,40,line), generic_horizontal_details( [ [ `Kunde`, q10( `:` ), q10( tab ), `Nr`, `.`, q10( tab( 200 ) ) ], nr, s1 ] )
	
	, check( i_user_check( get_scfb, nr, SCFB ) )
	
	, suppliers_code_for_buyer( SCFB )
	, trace( [ `SCFB`, SCFB ] )
	
] ).


i_user_check( get_scfb, Nr, SCFB ):- scfb_lookup( Nr, SCFB ).

scfb_lookup( `18364524`, `10126481` ):- grammar_set( test_flag ).
scfb_lookup( `18364524`, `18364524` ):- not( grammar_set( test_flag ) ).
scfb_lookup( `10128066`, `10128066` ).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
  
	q(0,25,line), generic_horizontal_details( [ [ `Bestellung`, `Nr`, `.` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	
	q(0,30,line), generic_horizontal_details( [ [ `Belegdatum`, `:` ], 200, invoice_date, date ] )
	
] ).

%=======================================================================
i_rule( get_delivery_date, [
%=======================================================================	  
	
	q(0,30,line), generic_horizontal_details( [ [ `Liefertermin`, `:` ], delivery_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ `Ansprechpartner`, `:` ], buyer_contact, s1 ] )
	
	, q10( [ check( buyer_contact = Con )
		, delivery_contact( Con )
	] )

] ).

%=======================================================================
i_rule( get_ddis, [ 
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ `Telefon`, `:` ], 200, buyer_ddi_x, s1 ] )

	, check( buyer_ddi_x = DDI )
	
	, check( strip_string2_from_string1( DDI, `- `, DDI_2 ) )
	, check( string_string_replace( DDI_2, `+49`, `0`, DDI_3 ) )

	, buyer_ddi( DDI_3 )
	, q10( [ without( delivery_ddi ), delivery_ddi( DDI_3 ) ] )

] ).

%=======================================================================
i_rule( get_faxes, [ 
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ `Fax`, `:` ], 200, buyer_fax_x, s1 ] )

	, check( buyer_fax_x = Fax )
	
	, check( strip_string2_from_string1( Fax, `- `, Fax_2 ) )
	, check( string_string_replace( Fax_2, `+49`, `0`, Fax_3 ) )
	
	, buyer_fax( Fax_3 )
	, q10( [ delivery_fax( Fax_3 ) ] )

] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ or( [ at_start, tab ] ), `EMail`, `:` ], 200, buyer_email, s1 ] )
	
	, q10( [ check( buyer_email = Email )
		, delivery_email( Email )
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Lieferanschrift`, `:` ] ] )
	  
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )

	, delivery_thing( [ delivery_party ] )
	
	, q10( [ qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
		, delivery_thing( [ delivery_dept ] )
	] )
	
	, q(0,2
		, [ qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) )
			, or( [ [ without( delivery_contact_x ), delivery_contact_line ], delivery_thing( [ delivery_address_line ] ) ] )
		]
	)
	 
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) ), delivery_thing( [ delivery_street ] )
	
	, qn0( gen_line_nothing_here( [ generic_hook(start), 10, 10 ] ) ), delivery_postcode_and_city_line
	
	, q10( [ q01(line), generic_horizontal_details( [ [ `Tel`, `.` ], delivery_ddix, s1 ] )
		, check( delivery_ddix = Ship )
		, shipping_instructions( Ship )
		, prepend( shipping_instructions( `Tel. ` ), ``, `` )
	] )
	
	, q10( [ without( delivery_contact_x ), with( invoice, buyer_contact, Con )
		, delivery_contact_x( Con )
	] )
	
] ).


%=======================================================================
i_line_rule_cut( delivery_thing( [ Variable ] ), [ nearest( generic_hook(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	  
	, q10( [ `DE`, `-` ] )

	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).


%=======================================================================
i_line_rule( delivery_contact_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	  
	, read_ahead( `Herr` )

	, generic_item( [ delivery_address_line, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================

	  q(0,40,line)
	  
	, generic_horizontal_details( [ [ read_ahead( [ `F`, `.`, `EE`, `-`, `Projekt` ] ), retab( [ 25 ] ) ], customer_comments, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	qn0(line), read_ahead( generic_horizontal_details( [ [ `Nettosumme`, `:` ], 200, total_net, d ] ) )

	, check( total_net = Net )
	, total_invoice( Net )

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
		
			  line_invoice_rule

			, line

		] )

	] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Pos`, `.`
	
	, or( [ [ peek_fails( test( type_two ) ), `F`, `.`, `EE`, `Artikel`, `-`, `Nr`, `.`, tab, header, set( type_one ) ]

		, [ peek_fails( test( type_one ) ), q10( tab ), `Artikelnummer`, tab, header, set( type_two ) ]
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ [ `Achtung`, `Folgeseite` ]
	
		, [ `Gewährleistung`  ]
		
		, [ `Zahlung` ]
	
		, [ q0n( [ dummy(s1), tab ] ), `Nettosumme` ] 
	
		, [ `*`, `*`, `*` ]
		
		, [ dummy, check( header(page) \= dummy(page) ) ]
	
	] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ read_ahead( dummy(s1) ), check( dummy(end) < 50 ), append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_item_line
	  
	, line_values_line
	
	, q10( line_continuation_line )
	
	, q10( [ check( projekt = Projekt )
		, append( line_descr( `~Projekt: ` ), ``, Projekt )
	] )
	
	, remove( projekt )
	
	, q10( check_for_uom_violation )
	
] ):- grammar_set( type_one ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_item_line
	
	, generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] )
	
	, qn0( line_continuation_line )
	
	, q10( check_for_uom_violation )
	
	, q10( [ with( invoice, delivery_date, Date )
		, line_original_order_date( Date )
	] )

] ):- grammar_set( type_two ).

%=======================================================================
i_rule_cut( check_for_uom_violation, [
%=======================================================================

	  check( line_quantity_uom_code = UoM )
	, check( q_sys_member( UoM, [ `VE`, `Set`, `Stange` ] ) )
	
	, delivery_note_reference( `special_rule` )
	, trace( [ `UoM VIOLATION - Document NOT processed` ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	
	, q10( generic_item( [ line_item_for_buyer, s1, tab ] ) )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	
	, q10( [ without( delivery_date ), read_ahead( generic_item( [ delivery_date, date ] ) ) ] )
	
	, generic_item( [ line_original_order_date, date ] )
	
	, q10( [ tab, projekt(s1) ] )
	
] ):- grammar_set( type_one ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] )
	  
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, w, [ q10( [ `(`, q0n(word) ] ), tab ] ] )
	
	, generic_item_cut( [ line_unit_amount, d, [ q10( [ `/`, dum(d) ] ), q10( tab ) ] ] )
	
	, q10( [ `-`, line_percent_discount(d), `%`, tab ] )
	
	, generic_item( [ line_net_amount, d, [ `EUR`, newline ] ] )

] ):- grammar_set( type_two ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  generic_item( [ line_descr, s1, tab ] )
	  
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, w, [ q10( [ `(`, q0n(word) ] ), tab ] ] )
	
	, generic_item_cut( [ line_unit_amount, d, q10( tab ) ] )

	, q10( [ `-`, line_percent_discount(d), `%`, tab ] )
	
	, generic_item( [ line_net_amount, d, [ `EUR`, newline ] ] )

] ):- grammar_set( type_one ).

