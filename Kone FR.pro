%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - KONE FR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( kone_fr, `05 May 2015` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `FR-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	%, currency( `4400` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]    % TEST
			, suppliers_code_for_buyer( `11727241` )     % PROD
	] )

%	, customer_comments( `Customer Comments` )
	, or( [ [ q0n(line), customer_comments_line ] , customer_comments( `` ) ])

%	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	, get_delivery_address

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	,[q0n(line), get_invoice_lines ]

	, [qn0(line), get_invoice_totals ]

	,[ q0n(line), get_shipping_instructions]


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  or( [ [ q0n(line), delivery_header_line

			, q01(line), delivery_party_line

			, q01(line), delivery_party_line_two

			, q(3, 0, line), delivery_street_line

			, q01(line), delivery_postcode_and_city
			
		]
		
		, delivery_note_reference( `no_delivery_address` )
		
	] )

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Adresse`, `de`, `livraison`

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
i_line_rule( delivery_party_line_two, [ 
%=======================================================================

	 append(delivery_party(s), ` `, ``)

	, check(delivery_party(end) < 0 )

	, trace([ `delivery party`, delivery_party ])
	

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	 delivery_street(s)

	, check(delivery_street(end) < 0 )

	, trace([ `delivery street`, delivery_street ])
	

]).

%=======================================================================
i_line_rule( delivery_postcode_and_city, [ 
%=======================================================================

	delivery_postcode( f( [ begin, q(dec,4,6), end ]) )

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, check(delivery_city(end) < 0 )

	, trace([ `delivery city`, delivery_city ])
	

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ 
%=======================================================================

	  invoice_date_header_line

	, q(0, 2, line), get_invoice_date_line

] ).

%=======================================================================
i_line_rule( invoice_date_header_line, [ 
%=======================================================================

	`Donneur`, `d`, `'`, `ordre`, tab, `TVA`, tab, `Date`

	, trace([ `invoice date header found` ])

] ).

%=======================================================================
i_line_rule( get_invoice_date_line, [ 
%=======================================================================

	q0n(anything)

	, invoice_date(date)

	, check(invoice_date(end) > 130 )

	, trace([ `invoice date`, invoice_date ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q(0,40,line), generic_vertical_details( [ [ `TVA`, tab, `N`, `°`, `Commande` ], `Commande`, order_number, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  buyer_contact_header_line

	, q(0, 5, line), get_buyer_contact_line

] ).

%=======================================================================
i_line_rule( buyer_contact_header_line, [ 
%=======================================================================

	`Adresse`, `de`, `livraison`

	, trace([ `buyer contact header found` ])

] ).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================

	read_ahead([ dummy(w), buyer_contact(w), `;` ])

	, append(buyer_contact(w), ` `, ``)

	, check(buyer_contact(end) < 0 )

	, trace([ `buyer contact`, buyer_contact ])

	, dummy(w)

	, `;`

 	, buyer_ddi( f( [ q(dec,2,2), begin, q(dec,5,10), end ]) )

	, prepend(buyer_ddi(`0`), ``, ``)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	get_invoice_totals_header

	, get_invoice_totals_line


]).

%=======================================================================
i_line_rule( get_invoice_totals_header, [
%=======================================================================

	`Devise`, tab, `Tot`, `.`, or( [ [ `Hors`, `Taxe` ], `Net` ] ),  gen_eof

	, trace( [ `totals header found` ] )


]).

%=======================================================================
i_line_rule( get_invoice_totals_line, [
%=======================================================================

	q0n(anything)

 	, read_ahead(total_net(d))

	, total_invoice(d)

	, newline

	, trace( [ `total inv`, total_invoice ] )


]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_lines, [
%=======================================================================

	q0n(line)	

	, line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ get_line_invoice, line ])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	`Pos`, `.`, `Ref`, tab, `Date`, `livr`, `.`, tab
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or([ [`2`, `(`, tab, `2`, `)`,  newline] 

	, [`1`, `(`, tab, `1`, `)`,  newline] ])

] ).

%=======================================================================
i_rule_cut( get_line_invoice, [ 
%=======================================================================

	get_line_values_line

	, get_line_descr_line

	, or([ [ q(0, 4, line), get_line_item_line] , line_item(`Missing`) ])

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_line_rule_cut( get_line_values_line, [
%=======================================================================
	 
	line_order_line_number_x(d), q01( [ some_thing(s1) ] ), tab

	, trace( [ `line order line number`, line_order_line_number] )	

	, line_original_order_date(date), tab

	, trace( [ `line original date`, line_original_order_date ] )	

	, line_quantity(d), line_quantity_uom_code(w), tab

	, trace( [ `line quantity`, line_quantity ] )	

	, line_unit_amount(d), `/`, tab

	, trace( [ `line unit amount`, line_unit_amount ] )

	, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, newline

] ).


%=======================================================================
i_line_rule_cut( get_line_descr_line, [
%=======================================================================

	 line_descr(s1), tab, num(d), uom(w), newline

	, trace( [ `line descr`, line_descr ]) 

] ).



%=======================================================================
i_line_rule_cut( get_line_item_line, [
%=======================================================================

	`mfr`, `.`, `part`, `nr`, `:`

	, line_item(s), newline

	, trace([ `line item`, line_item ])

] ).
