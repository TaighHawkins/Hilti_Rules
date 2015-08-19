%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - VOELKL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( voelkl, `23 January 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

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

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11205959` ) ]    %TEST
	    , suppliers_code_for_buyer( `10019151` )                      %PROD
	]) ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_order_number_date ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

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

	 , delivery_street_line

	 , delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Lieferadresse`, `/`, `Rechnungsadresse`, `:`,  newline

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	delivery_party(s1)

	, newline

	, trace([ `delivery party`, delivery_party ])
	
]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s1)

	, newline

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================
	
	`a`, `-`

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s1)

	, trace([ `delivery city`, delivery_city ])

	, newline

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(anything)

	,`S`, `.`, `Bearb`, `.`, `:`

	, or([ buyer_contact(w), buyer_contact(`.`) ])

	, append(buyer_contact(w), ` `, ``)

	, newline

	, trace( [ `buyer contact`, buyer_contact ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	,`tel`, `.`, `:`

	, `+`, `43`, `(`

	, buyer_ddi(sf), `)`

	, append(buyer_ddi(sf), ``, ``), `/`

	, append(buyer_ddi(sf), ``, ``), `-`

	, append(buyer_ddi(sf), ``, ``)

	, newline

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	,`mail`, `:`

	, buyer_email(s1)

	, newline

	, trace( [ `buyer email`, buyer_email ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number_date, [ 
%=======================================================================

	get_order_number_date_header

	, line

	, get_order_number_date_line

] ).

%=======================================================================
i_line_rule( get_order_number_date_header, [ 
%=======================================================================

	q0n(anything)

	,`Bestellung`, newline

	, trace( [ `order number header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_date_line, [ 
%=======================================================================

	q0n(anything)

	, order_number(s)

	, `vom`

	, invoice_date(date)

	, newline

	, trace( [ `order number`, order_number ] ) 

	, trace( [ `invoice date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`Nettowert`, `in`, `EUR`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

	, newline

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

		, or([ line_invoice_rule, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, or( [ [ `Artikel`, `-`, `Nr`, `.` ], [ q10( tab ), `ArtNr`, `.`, `/`, `WstNr`, `.`, q10( tab ) ] ] ), `Benennung` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Nettowert`, `in`, `EUR`, tab

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_values_line

	, or([ line_item_line, line_item_line_two, line_item(`Missing`) ])

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	line_order_line_number(d), q10( tab )

	, trace([ `line order line number`, line_order_line_number ])

	, line_item_for_buyer(s1), tab

	, trace([ `line item for buyer`, line_item_for_buyer ])

	, line_descr(s1), tab

	, trace([ `line description`, line_descr ])

	, q10([ line_original_order_date(date), tab

	, trace([ `line original order date`, line_original_order_date ]) ])

	, line_quantity(d), q01(tab)

	, trace([ `line quantity`, line_quantity ])

	, q10([ line_quantity_uom_code( f( [ begin, q(alpha,1,6), end ]) )

	, tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ]) ])

	, preis(d), tab
	
	, q01( [ disc(d), `%`, q10( tab ) ] )

	, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, newline

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	`art`, or([ `:`, `.` ]), q10( [ `Nr`, `.` ] ), q10( [ `:` ] )

	, line_item(f( [ begin, q(dec,3,10), end ] ) )

	, check(line_item(end) < -25 )

	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line_two, [
%=======================================================================

	q0n(anything)

	,`art`, `.`, `nr`, `.`, `lieferant`, `:`, tab

	, line_item(f( [ q(alpha("HI"),0,2), begin, q(dec,3,10), end ] ) )

	, newline

	, trace( [ `line item`, line_item ] )

] ).
