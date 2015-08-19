%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - ONI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( oni, `12 December 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `DE-ONI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10267671` ) ]    %TEST
	    , suppliers_code_for_buyer( `10287510` )                      %PROD
	]) ]

	, check_for_express_delivery

	, get_type_of_supply

	,or([ [q0n(line), get_delivery_address ], [q0n(line), get_delivery_address_two ] ])

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	, buyer_dept(`DEONI`)

	, delivery_from_contact(`DEONI`)

	,[q0n(line), due_date_line ]

	,[q0n(line), customer_comments_line ]

	,[q0n(line), shipping_instructions_line ]

	, get_invoice_lines

%	,[ qn0(line), invoice_total_line]
	, total_net(`0`), total_invoice(`0`)

	,[ qn0(line), buyer_dept_rule]
	

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPRESS DELIVERY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
ii_section( check_for_express_delivery, [ express_delivery_line ] ).
%=======================================================================
i_line_rule( express_delivery_line, [ 
%=======================================================================

	  q0n(anything), `express`
	
	, delivery_note_reference( `Express Delivery` )

] ):- not( grammar_set( test_flag ) ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DEPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( buyer_dept_rule, [ 
%=======================================================================

	buyer_dept_header_line

	, buyer_dept_line

] ).


%=======================================================================
i_line_rule( buyer_dept_header_line, [ 
%=======================================================================

	q0n(anything)

	, `Unterschrift`,  newline

] ).

%=======================================================================
i_line_rule( buyer_dept_line, [ 
%=======================================================================

	q0n(anything)

	, read_ahead(dummy(s1))

	, check(dummy(start) > 289)

	, read_ahead(append(buyer_dept(w), ``, ``))

	, append(delivery_from_contact(w), ``, ``)

	, newline

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_delivery_address, [
%=======================================================================
 
	 delivery_header_line( [ LEFT ] )

	 , or( [ [ q01(line), delivery_party_line( 3, LEFT, 500 ) ]

		, [ q(0,3,line), delivery_party_line( 1, LEFT, 500 ) ]
		
	] )

	 , q10( [ q(0, 2, line)

		, delivery_dept_line( 1, LEFT, 500 ) 
		
	] )

	 , q(0, 2, line)

	 , delivery_street_line( 1, LEFT, 500 )

	 , q(0, 2, line)

	 , delivery_postcode_city_line( 1, LEFT, 500 )

] ).

%=======================================================================
i_line_rule_cut( delivery_header_line( [ LEFT ] ), [ 
%=======================================================================

	`Kom`, `.`, `-`, `Nr`, `.`, `/`, `Fa`, `.`
	
	, q0n(anything), `Fax`, `/`, email(w)

	, trace([ `delivery header found` ])
	
	, check( i_user_check( gen_same, email(end), LEFT ) )

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	  retab( [ 8000 ] )
	  
	, peek_fails( [ q0n(word), or( [ `@`, [ `E`, `-`, `mail` ] ] ) ] )
	
	, delivery_party(s1)

	, trace([ `delivery party`, delivery_party ])
	
]).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	  retab( [ 501 ] )
	  
	, delivery_dept(s1)

	, trace([ `delivery dept`, delivery_dept ])

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	  retab( [ 501 ] )
	  
	, delivery_street(s1)

	, trace([ `delivery street`, delivery_street ])

	
	
]).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================

	  set( regexp_allow_partial_matching )
	  
	, delivery_postcode(f( [ begin, q(dec,5,5), end ] ) )
	  
	, delivery_city(f( [ begin, q(any,1,6), q(alpha,1,1), q(any,0,8), end ] ) )
	
	, clear( regexp_allow_partial_matching )

	, trace([ `delivery city`, delivery_city ])

]).

%=======================================================================
i_rule( get_delivery_address_two, [
%=======================================================================
 
	 delivery_header_line_two

	 , delivery_note_number_line_two

] ).

%=======================================================================
i_line_rule( delivery_header_line_two, [ 
%=======================================================================

	q0n(anything)

	,`Liefer`, `-`,  newline

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_note_number_line_two, [ 
%=======================================================================

	q0n(anything)

	, `oni`

	, or([ 
	       [ test(test_flag), delivery_note_number( `10267671` ) ]    %TEST
	        , delivery_note_number( `10287510` )                      %PROD
	]) 

	, trace([ `delivery note number`, delivery_note_number ])

	, newline
	
]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TYPE OF SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_type_of_supply, [ 
%=======================================================================

	q(0,25,line)
	
	, generic_horizontal_details( [ [ `Versandart`, `Anlieferung` ], 110, type_of_supply, s1 ] )
	
	, q10( [ 
		check( q_sys_sub_string( type_of_supply, _, _, `frei Haus / Baustelle` ) )
		, remove( type_of_supply )
		, type_of_supply( `S0` )
		, trace( [ `Type of supply changed`, type_of_supply ] )
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	, `Bestell`, `-`, `Nr`, `.`, `(`, `immer`, `angeben`, `)`, q10(tab)

	, order_number(s1)

	, check(order_number(end) < 280 )

	, trace( [ `order number`, order_number ] ) 


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_date, [ 
%=======================================================================

	q0n(anything)

, `Bestelldatum`, tab

	, invoice_date(date)

	, trace( [ `order date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUE DATE	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( due_date_line, [ 
%=======================================================================

	q0n(anything)

	, `Liefertermin`, `eintreffend`, tab

	, due_date(date)

	, trace( [ `due date`, due_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( customer_comments_line, [ 
%=======================================================================

	  customer_comments_header( [ Left ] )
	
	, q0n( or( [ customer_comments_line( 1, Left, 500 ), line ] ) )
	
	, generic_line( [ [ q0n(anything), `Lagermat` ] ] )

] ).

%=======================================================================
i_line_rule( customer_comments_header( [ Left ] ), [ 
%=======================================================================

	q0n(anything), ung, read_ahead( `stand` ), stand(w), newline

	, trace( [ `customer comments header found` ] ) 
	
	, check( i_user_check( gen_same, stand(end), Left ) )

] ).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	retab( [ 500 ] )
	
	, or( [ [ without( customer_comments ), generic_item( [ customer_comments, s1 ] ) ]
	  
		, [ with( customer_comments ), append( customer_comments(s1), `~`, `` ) ]
		
	] )
	
] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( shipping_instructions_line, [ 
%=======================================================================

	  with( invoice, customer_comments, Com )
	  
	, shipping_instructions( Com )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	q0n(anything)

	, `N`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

	, tab, `0`, `Lagermat`, `.`

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 	`Artikelbezeichnung`,  newline] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Wir`, `bitten`, `um`,  newline

] ).

%=======================================================================
i_line_rule_cut( get_invoice_line, [
%=======================================================================

	peek_fails([ nearest( 75, 20, 20), `0`, trace([ `zero line` ]) ])

	, line_order_line_number(d), tab

	, trace([ `line order line number`, line_order_line_number ])

	, gesamt(d), tab

	, lager(d), tab

	, q10([ or([ [line_quantity_uom_code(w), `.`], line_quantity_uom_code(w) ])

		, check(line_quantity_uom_code(start) > -388)

		, check(line_quantity_uom_code(end) < -324) ])

	, q10(tab)

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, line_descr(s1), tab, q0n([read_ahead(dummy(w)), check(dummy(start) < -50 ), append(line_descr(s1), ` `, ``), tab ])

	, trace([ `line description`, line_descr ])

	, q10([ line_item(s1), tab

	, check(line_item(start) > -30)
	
	, check(line_item(end) < 40)

	])

	, trace([ `line item`, line_item ])

	, peek_fails(`0`)

	, line_quantity(d), check(line_quantity(start) >20  ),  tab

	, trace([ `line quantity`, line_quantity ])

	, q10([einzelpreis(d), tab])

%	, q10([line_net_amount(d)

%	, trace([ `line net amount`, line_net_amount ])])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace( [ `original order date set to`, line_original_order_date ] )

] ).

%=======================================================================
i_analyse_invoice_fields_first
%-----------------------------------------------------------------------
:- i_rearrange_delivery_party.
%=======================================================================
%=======================================================================
i_rearrange_delivery_party
%-----------------------------------------------------------------------
:-
%=======================================================================
	result( _, invoice, delivery_party, Party ),
	string_to_lower( Party, PartyL ),
	q_sys_sub_string( PartyL, _, _, `montaplast` ),
	
	( result( _, invoice, delivery_dept, Dept )
		-> true
		;	Dept = ``
	),
	
	strcat_list( [ Party, ` `, Dept ], FullParty ),
	sys_string_length( FullParty, Length ),
	Length > 30,
	
	q_sys_sub_string( FullParty, 1, 30, NewParty ),
	q_sys_sub_string( FullParty, 31, _, NewDept ),
	
	sys_retractall( result( _, invoice, delivery_party, _ ) ),
	sys_retractall( result( _, invoice, delivery_dept, _ ) ),
	
	assertz_derived_data( invoice, delivery_party, NewParty, i_rearrange_delivery_party ),
	assertz_derived_data( invoice, delivery_dept, NewDept, i_rearrange_delivery_party ),
	
	!
.