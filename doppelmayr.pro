%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DOPPELMAYR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( doppelmayr, `19 March 2015` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, check_company

	, [q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), due_date_line ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]
	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

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
 
	, customer_comments( `` )
	, shipping_instructions( `` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK COMPANY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_company, [
%=======================================================================

	q(0,5,line), generic_horizontal_details( [ Search ] )
	
	, delivery_party( Party )
	, sender_name( Party )
	
	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( Test ) ]    %TEST
	    , suppliers_code_for_buyer( Prod )                      %PROD
	]) ]
	
] ):- company_lookup( Search, Party, Test, Prod ).

company_lookup( `Doppelmayr`, `Doppelmayr Seilbahnen GmbH`, `11205959`, `10010686` ).
company_lookup( `LTW`, `LTW Intralogistics GmbH`, `11205959`, `10040649` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	 delivery_header_line
	 
	, q01(line), delivery_street_line

	, q(0,2,line), delivery_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	q0n(anything)

	, `lieferadresse`, `:`

	, trace([ `delivery header found` ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	q0n( [ dummy(s1), tab ] )

	, delivery_street(s1)

	, check(delivery_street(start) > -10 )

	, trace([ `delivery street`, delivery_street ])

	, newline
	
]).

%=======================================================================
i_line_rule( delivery_city_line, [ 
%=======================================================================
	
	q0n( [ dummy(s1), tab ] )

	, delivery_postcode(d)

	, delivery_city(s)

	, check(delivery_city(start) > -10 )

	, trace([ `delivery city`, delivery_city ])

	, newline
	
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`Bestellung`, `Nr`, `.`, `/`, `Version`, tab

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

	, tab, `EinkäuferIn`

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_date, [ 
%=======================================================================

	`Bestelldatum`, tab

	, invoice_date(date)

	, trace( [ `order number`, order_number ] ) 

	, tab, `DisponentIn`

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(anything)

	, `DisponentIn`, tab

	, read_ahead([dummy(w), buyer_contact(w)])

	, append(buyer_contact(w), ` `, ``)

	, trace([ `buyer contact`, buyer_contact ])

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	,`Telefon`, `Nr`, `.`, tab, `+`

	, num(d), buyer_ddi(`0`)

	, append(buyer_ddi(w), ``, ``)

	, append(buyer_ddi(w), ``, ``)

	, append(buyer_ddi(w), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	, `e`, `-`, `mail`, tab

	, buyer_email(s1)

	, trace([ `buyer email`, buyer_email ])

	, newline

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

	`Gesamtbetrag`, tab, `EUR`, tab

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
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
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
i_line_rule_cut( line_header_line, [ `Ihre`, `Nr`, `.`, tab, `Ihre`, `Artikelbezeichnung`,  newline ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [ `Gesamtbetrag`, tab, `EUR`, tab ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_section_line, [ 
%=======================================================================

	or( [ [ `Seite`, tab ]
	
		, [ `Bank`, `für`, `Tirol` ]
		
		, [`Doppelmayr`, `Seilbahnen`, `GmbH`]
		
	] )
	
] ).



%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	line_values_line

	, read_ahead([ q(0, 2, line), line_original_order_date_line ])

	, or([ [q(0, 10, [ peek_fails( line_check_line ), line ] ), line_item_code_line], line_item_code_line_two, line_item(`Missing`) ])

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
	
] ).


%=======================================================================
i_line_rule_cut( line_check_line, [ q0n(anything), q(2,2,[ tab, dum(d) ] ), newline ] ).
%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	pos(s1), tab

	, line_item_for_buyer(s1), tab

	, trace([ `line item for buyer`, line_item_for_buyer ])

	, line_descr(s1), tab

	, q01([ append(line_descr(s), ` `, ``), tab ])

	, trace([ `line description`, line_descr ])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	, line_quantity_uom_code(w), tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, preis(d), `/`, num(d), tab

	, grundbertag(d), tab

	, line_net_amount(d)

	, trace([ `line net amount`, line_net_amount ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_original_order_date_line, [
%=======================================================================

	q10([dummy_no(s1), tab])

	,`Lieferdatum`, tab

	, line_original_order_date(date)

	, trace([ `line original order date`, line_original_order_date ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_item_code_line, [
%=======================================================================

	 or( [ [ `ART`, `.`, `NR`, `.`, q10(`:`), line_item(sf), or( [ gen_eof, `HILTI` ] ) ]
	 
		, line_item( f( [ begin, q(dec,4,10), end ] ) )
	] )

	, trace([ `line item`, line_item ])

] ).

%=======================================================================
i_line_rule_cut( line_item_code_line_two, [
%=======================================================================

	 q0n(anything), `artnr`, `.`, `:`

	, line_item(sf), or( [ gen_eof, `HILTI` ] )

	, trace([ `line item`, line_item ])

] ).
