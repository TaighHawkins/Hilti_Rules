%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - STADLER + SHAAF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( stadler_shaaf, `8 April 2015` ).

i_pdf_parameter( same_line, 6 ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, gen_capture( [ `Belegnummer`, order_number, s1 ] )
	, gen_vert_capture( [ [ gen_beof, `vom`, newline ], invoice_date, date, newline ] )
	
	, get_delivery_details
	
	, get_buyer_delivery_contact
	, gen_capture( [ [ `E`, `-`, `Mail` ], 200, buyer_email, s1, newline ] )
	, gen_capture( [ [ `E`, `-`, `Mail` ], 200, delivery_email, s1, newline ] )
	, get_buyer_delivery_ddi
	, get_buyer_delivery_fax

	, get_invoice_lines
	
	, get_totals

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
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Stadler + Schaaf GmbH` )

	, suppliers_code_for_buyer( `10176048` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================	  

	or( [
	
		get_delivery_address_rule
		
		, delivery_note_number(`10176048`)
		
	] )
	
	, trace( [ `got delivery details` ] )
	
] ).

%=======================================================================
i_rule( get_delivery_address_rule, [
%=======================================================================	  

	q0n(line)
	
	, generic_horizontal_details( [ read_ahead( [ `Versandanschrift`, `:` ] ), delivery_left_margin, s1, newline ] )
	
	, delivery_thing( [ delivery_party, s1 ] )
	
	, delivery_thing( [ delivery_dept, s1 ] )
	
	, q(1,2, delivery_thing( [ delivery_address_line, s1 ] ) )
	
	, delivery_thing( [ delivery_street, s1 ] )
	
	, delivery_postcode_and_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_thing( [ Variable, Type ] ), [
%=======================================================================	  

	nearest( delivery_left_margin(start), 10, 10 )
	
	, generic_item( [ Variable, Type ] )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================	  

	nearest( delivery_left_margin(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_delivery_contact, [
%=======================================================================

	q(0,20,line)
	
	, contact_line

] ).

%=======================================================================
i_line_rule( contact_line, [
%=======================================================================

	`Kontakt`, tab
	
	, surname(w), `,`
	
	, buyer_contact(s1)
	, check( surname = Surname )
	, append( buyer_contact(Surname), ` `, `` )
	
	, check( buyer_contact = Contact )
	, delivery_contact(Contact)
	
	, trace( [ `Contact`, Contact ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER DELIVERY DDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_delivery_ddi, [
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ `Telefon`, 200, ddi, s1 ] )
	
	, check( strip_string2_from_string1( ddi, ` /-`, DDI ) )
	
	, buyer_ddi(DDI)
	, delivery_ddi(DDI)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER DELIVERY FAX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_delivery_fax, [
%=======================================================================

	q(0,20,line)
	
	, generic_horizontal_details( [ `Fax`, 250, fax, s1 ] )
	
	, check( strip_string2_from_string1( fax, ` /-`, Fax ) )
	
	, buyer_fax(Fax)
	, delivery_fax(Fax)

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
i_line_rule( line_section_end_line, [ `Stadler`, `+`, `Schaaf` ] ).
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

	`EUR`, tab, `EUR`, newline
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Für`, `die`, `oben`, `aufgeführten`
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
	, q01(line)
	
	, generic_horizontal_details( [ at_start, line_item, [ begin, q(dec,4,10), end ], newline ] )
	
	, q01(line)
	
	, generic_horizontal_details( [ [ at_start, `Liefertermin`, `:` ], line_original_order_date, date, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	q10( generic_no( [ line_order_line_number, d, tab ] ) )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1 ] )
	
	, q10( [ tab, a(d)
	
		, q10( [ `-`, a(d) ] )
		
	] )
	
	, or( [
	
		[ tab, generic_item( [ line_net_amount, d ] )
	
			, check( line_net_amount(start) > 350 )
			
		]
		
		, [ line_net_amount(`1`), set( no_line_nets ) ]
		
	] )
	
	, newline

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line)
	
	, or( [
	
		[ peek_fails( test( no_line_nets ) )
			, generic_horizontal_details( [ [ read_ahead(`Gesamtpreis`), gesamtpreis(w) ] ] )
			, check( gesamtpreis(start) = Left )
			, q0n( or( [ total_net_line(1,Left,500), line ] ) )
		]
		
		, [ test( no_line_nets )
			, generic_horizontal_details( [ [ read_ahead( `Pos` ), pos(w), tab, `Artikel` ] ] )
			, check( pos(end) = Right )
			, q0n( or( [ total_net_line_2(1,-500,Right), line ] ) )
		]
			
	] )
	
	, line_end_line
	
	, trace( [ `total_invoice`, total_invoice ] )

] ).

%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================

	net(d), newline
	
	, or( [
	
		[ with( invoice, total_net, Net ), check( sys_calculate_str_add( net, Net, Tot ) ) ]
		
		, check( net = Tot )
		
	] )
	
	, total_net(Tot)
	, total_invoice(Tot)

] ).

%=======================================================================
i_line_rule( total_net_line_2, [
%=======================================================================

	net(d)
	
	, or( [
	
		[ with( invoice, total_net, Net ), check( sys_calculate_str_add( `1`, Net, Tot ) ) ]
		
		, check( `1` = Tot )
		
	] )
	
	, total_net(Tot)
	, total_invoice(Tot)

] ).