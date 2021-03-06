%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - ALUSOMMER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( alusommer, `10 December 2014` ).

i_date_format( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	total_net(`0`)

	%, total_vat(`0`)

	, total_invoice(`0`)

	, set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ q0n(line), suppliers_code_for_buyer_line ]

%	, suppliers_code_for_buyer( `10041470` )    % PROD
%	, suppliers_code_for_buyer( `11205957` )    % TEST

%	, customer_comments( `Customer Comments` )
	
%	, [ q0n(line), customer_comments_line ] 

%	, [ q0n(line), shipping_instructions_line ] 

%	, shipping_instructions( `Shipping Instructions` )
%	, shipping_instructions( `` )

%	,[q0n(line), get_delivery_party_line ]

%	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_email ]

	, get_invoice_lines

	,[ q0n(line), get_invoice_totals]


] ).


%=======================================================================
i_line_rule( suppliers_code_for_buyer_line, [ 
%=======================================================================

	`lieferkonditionen`, q0n(anything), `werk`, `stoob`
	
	, or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11205957` ), delivery_note_number( `11205957` )  ]    %TEST
	    , [ suppliers_code_for_buyer( `10041470` ), delivery_note_number( `10041470` ) ]                      %PROD
	])


	, trace([ `werk stoob`, suppliers_code_for_buyer ]) 

	
]).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_party_line, [ 
%=======================================================================

	`Lieferadresse`, tab
	
	, delivery_party(s)

	, trace([ `delivery party`, delivery_party ]) 

	
]).


%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  

	  delivery_header_line

	, delivery_dept_line

 	, delivery_city_line

]).


 	
%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	
	`Lieferadresse`, tab

	, trace([ `delivery header found` ])
	

]).


%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	delivery_dept(s1)

	, trace([ `delivery dept`, delivery_dept ]) 

	
]).

%=======================================================================
i_line_rule( delivery_city_line, [ 
%=======================================================================

	q10([anyword(w), `-`])

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ]) 

	, or([ [delivery_city(w), `,`], [delivery_city(s), `,` ] ])

	, trace([ `delivery city`, delivery_city ]) 

	, delivery_street(s)

	, trace([ `delivery street`, delivery_street ]) 

	
]).	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	q0n(anything)

	, `Stoob`, `,`, q10( `am` )

	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	`Bestellung`, `:`

	, order_number(s)

	, trace( [ `order number`, order_number ] ) 

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

	,`Bearbeiter`, `:`, tab

	, buyer_contact(s)

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	,`tel`, `.`, `:`, tab

	, or([ [`+`, num(d), buyer_ddi(`0`), `(`, append(buyer_ddi(d), ``, ``), `)`, append(buyer_ddi(s), ``, ``) ]

		, [ wrap(buyer_ddi(f([ q(dec("0"),2,2), q(dec, 2, 2), begin, q(dec, 1, 15), end ])), `0`,``)  ]

		, buyer_ddi(s)

		])

	, newline

] ).


%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	,`email`,  `:`, tab

	, buyer_email(s)

	, newline

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [ test( totals_needed ), 
%=======================================================================

	q0n(line), total_net_line

%	, q0n(line), total_vat_line

	, q0n(line), total_invoice_line

] ).


%=======================================================================
i_line_rule( total_net_line, [
%=======================================================================

	`Netto`, tab

	,total_net(d), newline

	,trace( [ `total net`, total_net ] )

	


] ).

%=======================================================================
i_line_rule( total_vat_line, [
%=======================================================================


	`+`, `20`, `%`, `Mwst`, `.`, tab

	,total_vat(d), newline

	,trace( [ `total vat`, total_vat ] )

	


] ).



%=======================================================================
i_line_rule( total_invoice_line, [
%=======================================================================

	`Gesamtbetrag`, `[`, or( [ `€`, `EUR` ] ), `]`, tab

	,total_invoice(d), newline

	,trace( [ `total invoice`, total_invoice ] )	

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

		, or([ get_invoice_line, invoice_line_with_item, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	
   	`Menge`, tab, or( [ `ArtikelNr`, [ `Artikel`, `-`, `Nr`, `.` ] ] ), tab, `Bezeichnung`



] ).


%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================


	q0n(anything)

	, `Bankverbindung`, `:`, `BANK`, `AUSTRIA`, `CREDITANSTALT`

] ).


%=======================================================================
i_line_rule_cut( invoice_line_with_item, [
%=======================================================================

	  generic_item( [ line_quantity, d, q10( tab ) ] )

	, q10([ uom_code(w) ]), line_quantity_uom_code(`EA`)

%	, or([ [`stk`, line_quantity_uom_code(`EA`)]

%	, [`stg`, line_quantity_uom_code(`EA`)] ])

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, generic_item( [ line_item, s1, tab ] )

	, generic_item( [ line_descr, s1 ] )
	
	, or( [ [ tab, q0n(anything), tab

			, generic_item( [ line_net_amount, d, newline ] )
			
			, set( totals_needed )
			
		]
		
		, [ tab, `€`, generic_item( [ line_unit_amount, d, generic_item( [ line_percent_discount, d, [ `%`, newline ] ] ) ] ) ]
		
		, [ newline, line_net_amount( `0` ) ]
		
	] )

] ).





%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	get_line_invoice_line

	, q(0,4,[ peek_fails( line_check_line ), line ] ), get_item_code_line

] ).

%=======================================================================
i_line_rule_cut( line_check_line, [ dummy(s1), check( dummy(start) < -350 ) ] ).
%=======================================================================
i_line_rule_cut( get_line_invoice_line, [
%=======================================================================

	 line_quantity(d), q10(tab)

	, trace([`line quantity`, line_quantity])

	, q10([ uom_code(w) ]), q10(tab), line_quantity_uom_code(`EA`)

%	, or([ [`stk`, line_quantity_uom_code(`EA`)]

%	, [`stg`, line_quantity_uom_code(`EA`)] ])

	, trace([`line quantity uom code`, line_quantity_uom_code ])

	, line_item_for_buyer(s1), tab

	, trace([`line item for buyer`, line_item_for_buyer ])

	, line_descr(s1)
	
	, or([ [ tab, q01(`€`), unitamount(d)

			, trace([`line descr`, line_descr ])
			
			, q0n(anything)

			, line_net_amount(d) 
			
			, set( totals_needed )
		
		]
		
	, [ line_net_amount(`0`), total_net(`0`), total_invoice(`0`) ] ])

	, newline

] ).

%=======================================================================
i_line_rule_cut( get_item_code_line, [
%=======================================================================

	or( [ line_item(w), line_item( `Missing` ) ] )

	, trace([ `line item`, line_item ])

	, q0n(anything)

	, `lt`, `:`

	, line_original_order_date(date)

	, trace([ `line original order date`, line_original_order_date ])

] ).

