%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SCHMIDHAMMER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( schmidhammer, `22 June 2015` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	%, suppliers_code_for_buyer( `10672877` )
	%, suppliers_code_for_buyer( `12975631` )


	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10672877` ) ]    %TEST
	    , suppliers_code_for_buyer( `12975631` )                      %PROD
	]) ]

%	, customer_comments( `Customer Comments` )
%	, or( [ [ q0n(line), customer_comments_line ] , customer_comments( `` ) ])

%	, customer_comments( `` )

%	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line),  get_order_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[ q0n(line), get_general_original_order_date]

	, get_invoice_lines

	, total_vat(`0`)

	, total_invoice(`0`)

	, get_invoice_totals

	, [ q0n(line), total_invoice_line ]

	, replicate_address

	, [ q0n(line), get_customer_comments ]

	
] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	cup_line

	, q01(line)

	, cig_line

	

]).

%=======================================================================
i_line_rule( cup_line, [ 
%=======================================================================

	`cup`, `:`

	, customer_comments(`CUP: `)

	, append(customer_comments(s1), ``, ``)

]).

%=======================================================================
i_line_rule( cig_line, [ 
%=======================================================================

	`cig`, `:`

	, append(customer_comments(` CIG: `), ``, ``)

	, append(customer_comments(s1), ``, ``)

]).


%=======================================================================
i_line_rule( total_invoice_line, [ 
%=======================================================================

	`totale`, tab, read_ahead(total_invoice(d)), total_net(d), newline

	, trace( [ `total invoice`, total_invoice ] )

]).


%=======================================================================
i_rule( replicate_address, [
%=======================================================================

	q10([ with(invoice, buyer_contact, BC), delivery_contact(BC) ])

	, q10([ with(invoice, buyer_email, BE), delivery_email(BE) ])

	, q10([ with(invoice, buyer_ddi, BI), delivery_ddi(BI) ])

	, q10([ with(invoice, buyer_fax, BF), delivery_ddi(BF) ])


] ).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERAL ORIGINAL ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_general_original_order_date, [ 
%=======================================================================

	original_order_date_header_line

	, get_line_original_order_date_line

]).

%=======================================================================
i_line_rule( original_order_date_header_line, [ 
%=======================================================================

	`Fornitore`, tab, `Termine`, `di`, `consegna`

	, trace( [ `line original order date header found` ] )

]).

%=======================================================================
i_line_rule( get_line_original_order_date_line, [ 
%=======================================================================

	q0n(anything)

	, due_date(date)

	, check(due_date(start) > -150 )

	, check(due_date(end) < 0 )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  delivery_header_line

	 , q(1, 1, line), delivery_party_line

	 , delivery_street_line

	 , delivery_city

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Destinazione`, `merce`

	, trace([ `delivery header found` ])
	

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================
	
	delivery_party(s)

	, trace([ `delivery party`, delivery_party ])

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s)

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
i_line_rule( delivery_city, [ 
%=======================================================================
	
	q01( [ postc(w), `-` ] )
	
	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ])

	, `(`, delivery_state(w), `)`

	, trace([ `delivery state`, delivery_state ])
	

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	order_date_header_line

	, get_order_date_line

]).

%=======================================================================
i_line_rule( order_date_header_line, [ 
%=======================================================================

	`Fornitore`, tab, `Termine`, `di`, `consegna`

	, trace( [ `invoice date header found` ] )

]).

%=======================================================================
i_line_rule( get_order_date_line, [ 
%=======================================================================

	q0n(anything)
	
	, invoice_date(date)

	, check(invoice_date(start) > 335 )

	, trace( [ `invoice date`, invoice_date] )

	, newline

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	order_number_header_line

	, get_order_number_line

]).

%=======================================================================
i_line_rule( order_number_header_line, [ 
%=======================================================================

	`Fornitore`, tab, `Termine`, `di`, `consegna`

	, trace( [ `order number header found` ] )

]).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	q0n(anything)
	
	, order_number(s)

	, check(order_number(start) > 250 )

	, check(order_number(end) < 340 )

	, trace( [ `order number`, order_number ] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	buyer_contact_header_line

	, get_buyer_contact_line

]).

%=======================================================================
i_line_rule( buyer_contact_header_line, [ 
%=======================================================================

	`Fornitore`, tab, `Termine`, `di`, `consegna`

	, trace( [ `buyer contactheader found` ] )

]).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================

	q0n(anything)
	
	, buyer_contact(s)

	, check(buyer_contact(start) > -20 )

	, check(buyer_contact(end) < 165 )

	, trace( [ `buyer contact`, buyer_contact ] )

]).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	`tel`, `.`,`:`, tab

	, num(d)

	, buyer_ddi(w), append(buyer_ddi(w), ``, ``), append(buyer_ddi(w), ``, ``)

	, trace([ `buyer ddi`, buyer_ddi ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	q0n(line)

 	, line_header_line

	, total_net(`0`)

	, qn0( [ peek_fails(line_end_line)

		, or([ value_line, line

			])

		] )

] ).


%=======================================================================
i_line_rule_cut( value_line, [
%=======================================================================

	q0n(anything)

	, net_amount(d), newline

	, trace([ `net amount`, net_amount ])

	, check(net_amount(start) > 350)

	, check( i_user_check( gen_str_add, total_net, net_amount, NEW_TOTAL) )

	, total_net(NEW_TOTAL)

	, total_invoice(NEW_TOTAL)

	, trace([ `new total net`, total_net ])

	
	

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

	, qn1( [ peek_fails(line_end_line)

		, or([  get_invoice_line

		,  get_invoice_line2, get_invoice_line3, get_invoice_line4


			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Articolo`, tab, read_ahead( `Descrizione` ), descr_hook(s1), tab, qty_hook(w)] ).
%=======================================================================


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Distinti`, `saluti`,  newline

] ).



%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	 invoice_line_line

	, q10([ or([ invoice_line_cont, [ peek_fails(test(got_item)),line_item(`missing`) ]  ]) ])

	, clear(got_item)



] ).


%=======================================================================
i_line_rule( invoice_line_cont, [
%=======================================================================

	test(missing_item)

	, or([ [ test(art_next), line_item(d) ], [ read_ahead([ dummy(s), newline, check(dummy(start) > -350) ]), `art`, `no`, `.`, `:`, line_item(d) ] ])


] ).



%=======================================================================
i_line_rule_cut( invoice_line_line, [
%=======================================================================

	or([ [line_item( f( [ begin, q(dec,4,10), end ] ) ), tab
			, set(got_item)
			, check( line_item(end) < descr_hook(start) )
		]
	
		, [ read_ahead([ q0n(word), q10( [ `art`, `.`, `:` ] )
			, line_item(f( [ begin, q(dec,4,10), end ] )), set(got_item) ]) 
		]
		
		, set(missing_item) 
		
	])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace([ `line item`, line_item ])

	, line_descr(sf)
	
	, q10( [ tab, extra_descr(s1), check( extra_descr(end) < qty_hook(start) )
		, check( extra_descr = Extra )
		, append( line_descr( Extra ), ` `, `` )
	] )

	, q10([ `art`, `.`, `:`, set(art_next) ] )

	, tab

	, trace([ `line descr`, line_descr ])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	, or([ [ or( [ `pz`, [ `a`, `.`, `c`, `.` ] ] ), line_quantity_uom_code(`EA`)]
	
		, [`ml`, line_quantity_uom_code(`M`)]
		
	])

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, q10([ q0n(anything)

	, line_net_amount(d)

	, check(line_net_amount(start) > 350)

	, newline ])

	, trace([ `line net amount`, line_net_amount ])

	 , trace( [ `original order date set to`, line_original_order_date ] )

	

] ).



%=======================================================================
i_rule_cut( get_invoice_line2, [
%=======================================================================

	get_line_invoice_line2

	, line_uom_line2

	, line_item_code_line2
	

] ).

%=======================================================================
i_line_rule_cut( get_line_invoice_line2, [
%=======================================================================

	line_descr(s1), tab

	, trace([ `line descr`, line_descr ])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	

] ).


%=======================================================================
i_line_rule_cut( line_uom_line2, [
%=======================================================================

	`,`, numb(d)

	,or([ [`pz`, line_quantity_uom_code(`EA`)], [`ml`, line_quantity_uom_code(`M`)] ])

	, trace([ `line quantity`, line_quantity ])

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, q10([ q0n(anything)

	, line_net_amount(d)

	, check(line_net_amount(start) > 350)

	, newline ])

	, trace( [ `original order date set to`, line_original_order_date ] )

	

] ).


%=======================================================================
i_line_rule_cut( line_item_code_line2, [
%=======================================================================

	cod(w), `.`

	, line_item(w)

	, trace([ `line item`, line_item ])

	, newline

	
] ).

%=======================================================================
i_rule_cut( get_invoice_line3, [
%=======================================================================

	get_line_invoice_line3

	, line_item_code_line3
	

] ).

%=======================================================================
i_line_rule_cut( get_line_invoice_line3, [
%=======================================================================

	line_item(s1), tab

	, trace([ `line item`, line_item ])

	, line_descr(s1), tab

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace([ `line descr`, line_descr ])

	, q10([linedescr(s), tab])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	

] ).

%=======================================================================
i_line_rule_cut( line_item_code_line3, [
%=======================================================================

	`,`, numb(d)

	,or([ [`pz`, line_quantity_uom_code(`EA`)], [`ml`, line_quantity_uom_code(`M`)] ])

	, trace([ `line quantity`, line_quantity ])

	, q10([ q0n(anything)

	, line_net_amount(d)

	, check(line_net_amount(start) > 350)

	, newline ])

	, trace( [ `original order date set to`, line_original_order_date ] )


	

] ).

%=======================================================================
i_rule_cut( get_invoice_line4, [
%=======================================================================

	get_line_invoice_line4

	, line_uom_code_line4
	

] ).

%=======================================================================
i_line_rule_cut( get_line_invoice_line4, [
%=======================================================================

	line_item(`Missing`)

	, trace([ `line item`, line_item ])

	, line_descr(s1), tab

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, trace([ `line descr`, line_descr ])

	, q10([linedescr(s), tab])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	

] ).

%=======================================================================
i_line_rule_cut( line_uom_code_line4, [
%=======================================================================

	`,`, numb(d)

	,or([ [`pz`, line_quantity_uom_code(`EA`)], [`ml`, line_quantity_uom_code(`M`)] ])

	, trace([ `line quantity`, line_quantity ])

	, q10([ q0n(anything)

	, line_net_amount(d)

	, check(line_net_amount(start) > 350)

	, newline ])

	, trace( [ `original order date set to`, line_original_order_date ] )


		

] ).





