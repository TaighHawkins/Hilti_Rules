%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CARRIER TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( carrier_test, `22 April 2015` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11205959` ) ]    %TEST
	    , suppliers_code_for_buyer( `10014679` )                      %PROD
	]) ]

	, customer_comments( `` )
	, shipping_instructions( `` )

	,[q0n(line), get_delivery_address ]

	,[q(0, 10, line), get_order_number ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), due_date_line ]

	%, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]
	


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	 delivery_header_line

	, delivery_party_line
	
	, q01(line)

	, delivery_street_line

	, delivery_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	 `Bitte`, `liefern`, `sie`, `an`, `:`

	, trace([ `delivery header found` ])
	

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================
	
	 delivery_party(s)

	, check(delivery_party(end) < 0 )

	, trace([ `delivery party`, delivery_party ])
	

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	 delivery_street(s1)

	, check(delivery_street(end) < -100 )

	, trace([ `delivery street`, delivery_street ])
	

]).

%=======================================================================
i_line_rule( delivery_city_line, [ 
%=======================================================================
	

	q(0,2,word)

	, delivery_postcode( f( [ begin, q(dec,3, 5), end ]) )

	, delivery_city(s1)

	, check(delivery_city(end) < -100 )

	, trace([ `delivery city`, delivery_city ])
	

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	with(delivery_postcode)

	, order_number_header

	, order_number_line


] ).


%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	q0n(anything)

	, order_number(s)

	, `/`, invoice_date(date), newline

	, trace( [ `order number`, order_number ] ) 


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	buyer_contact_header

	, buyer_contact_line



] ).


%=======================================================================
i_line_rule( buyer_contact_header, [ 
%=======================================================================

	q0n(anything)

	, `ansprechpartnerIN`


] ).


%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	q0n(anything)

	, buyer_dept(sf)

	, check(buyer_dept(start) > -10)

	, q10( `/` )

	, prepend(buyer_dept(`ATHEDA`), ``, ``)

	, trace([ `buyer contact`, buyer_contact ])

] ).



%=======================================================================
i_line_rule( due_date_line, [ 
%=======================================================================

	q0n(anything)

	, `liefertermin`, q01(tab)

	, due_date(date)

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`gesamtnettowert`
	
	, `ohne`, `mwst`, `eur`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

	, newline


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

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line, line ])

		] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, `Wert`,  newline ] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [ `hilti`, `ges` ], [ `gesamtnettowert` ] ])

] ).



%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	posex_line, q01(line), line_quantity_line

	, get_line_item

	, get_netto_line

	, q10( [ peek_fails( test(netto_price) ), get_brutto_line ])
	
] ).


%=======================================================================
i_line_rule_cut( posex_line, [
%=======================================================================

	line_order_line_number( f( [ begin, q(dec,3, 3), end ]) ), tab

	, trace([ `line number`, line_order_line_number ])

	, q01([ wert(s), tab ])

	, line_descr(s1), newline

	, trace([ `line description`, line_descr ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

] ).



%=======================================================================
i_line_rule_cut( line_quantity_line, [
%=======================================================================

	read_ahead(dummy(w)), check(dummy(start) < -250), check(dummy(start) > -330)

	, line_quantity(d), q10(tab)

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w), newline

	, trace([ `line uom`, line_quantity_uom_code ])

	

] ).

%=======================================================================
i_rule_cut( get_line_item, [
%=======================================================================

	or([

		read_ahead([ 

			qn1([ peek_fails(line_end_line), peek_fails(posex_line), or([ line_item_line, line ]) ])

		])

		, line_item(`MISSING`)

	])

]).


%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	`ihre`, `materialnummer`, q01(tab), line_item(s)

	, trace([ `line item`, line_item ])
	

] ).


%=======================================================================
i_rule_cut( get_netto_line, [
%=======================================================================

	clear( netto_price )

	, read_ahead([ 

		qn1([ peek_fails(line_end_line), peek_fails(posex_line), or([ netto_line, line ]) ])

	 ])

]).


%=======================================================================
i_line_rule_cut( netto_line, [
%=======================================================================

	`nettowert`, tab, q0n(anything), line_net_amount(d), newline

	, set( netto_price )

	, trace([ `netto`, line_net_amount ])


] ).

%=======================================================================
i_rule_cut( get_brutto_line, [
%=======================================================================

	read_ahead([ 

		qn1([ peek_fails(line_end_line), peek_fails(posex_line), or([ brutto_line, line ]) ])

	 ])

]).


%=======================================================================
i_line_rule_cut( brutto_line, [
%=======================================================================

	`bruttopreis`, tab, q0n(anything), line_net_amount(d), newline

	, trace([ `brutto`, line_net_amount ])


] ).

