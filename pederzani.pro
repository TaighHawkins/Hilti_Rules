%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - PEDERZANI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( pederzani, `07 April 2015` ).



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

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10672877` ) ]    %TEST
	    , suppliers_code_for_buyer( `13033688` )                      %PROD
	]) ]


%	, suppliers_code_for_buyer( `10672877` ) % TEST
%	, suppliers_code_for_buyer( `13033688` ) %PROD

	, get_customer_comments

%	, shipping_instructions( `Shipping Instructions` )
%	, shipping_instructions( `` )

	, delivery_party(`PEDERZANI IMPIANTI SRL`) 

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	, get_order_date

	,[q0n(line), get_buyer_contact ]

	, get_invoice_lines

	,[ q0n(line), get_net_total_number]

	,[ q0n(line), get_invoice_total_number]

	, replicate_address


] ).


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
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  delivery_party(`PEDERZANI IMPIANTI SRL`)

	, buyer_email( `info@pederzani.it` )
	, buyer_ddi(`0376781281` )

	, delivery_header_line

	 , q(0,2,line)

	 , delivery_dept_line

 	, q(0,2,line)

	 , delivery_street_line

	 , q(0,2,line)

	 , delivery_postcode_and_city

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	q0n(anything)

	,`Destinazione`, `merce`

	, trace([ `delivery header found` ])
	

]).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================

	q0n(anything)

	, delivery_dept(s), newline

	, check(delivery_dept(start) > 30 )

	, trace([ `delivery dept`, delivery_dept ])
	

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	q0n(anything)

	, delivery_street(s), newline

	, check(delivery_street(start) > 30 )

	, trace([ `delivery street`, delivery_street ])
	

]).

%=======================================================================
i_line_rule( delivery_postcode_and_city, [ 
%=======================================================================

	q0n(anything)

	, delivery_postcode(d)

	, check(delivery_postcode(start) > 30 )

	, trace([ `delivery postcode`, delivery_postcode ])

	, or([ [ delivery_city(s),`(`, delivery_state(w), `)` ], delivery_city(s) ]) 

	, newline

	, trace([ `delivery city`, delivery_city ])
	

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

	,q(0, 3, line), order_date_line


] ).

%=======================================================================
i_line_rule( order_date_header_line, [ 
%=======================================================================

	q0n(anything)

	, `data`, tab, `pag`, newline

] ).

%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================


	 q0n(anything)

	, invoice_date(date)

	, trace( [ `invoice date`, invoice_date] )

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

	, q(0, 3, line), order_number_line

] ).



%=======================================================================
i_line_rule( order_number_header_line, [ 
%=======================================================================

	q0n(anything)

	,`numero`, tab, `data`

	, trace([ `order number header found` ])
] ).




%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	 q0n(anything)

	, or([ [ order_number(w), `.`, append(order_number(w), ``, ``) ], order_number(s) ])

	, check(order_number(start) > 240 )

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	  q0n(line), customer_comments_header

	, customer_comments_line

] ).

%=======================================================================
i_line_rule( customer_comments_header, [ 
%=======================================================================

	`Note`, newline

] ).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	 customer_comments(s1)
	 
	, check( customer_comments(start) < 0 )
	
	, prepend( customer_comments( `Note = ` ), ``, `` )
	
	, newline
	
	, trace( [ `customer comments`, customer_comments ] )

	, check( i_user_check( gen_same, customer_comments, SHIP ) )
	
	, shipping_instructions( SHIP )
	  
	, trace( [ `shipping instructions`, shipping_instructions ] )
	
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

	, q(0, 2, line), get_buyer_contact_line

] ).

%=======================================================================
i_line_rule( buyer_contact_header_line, [ 
%=======================================================================

	q0n(anything)

	, `da`, `:`, tab, `a`, `:`

	, trace([ `buyer contact header found` ])

] ).

%=======================================================================
i_line_rule( get_buyer_contact_line, [ 
%=======================================================================

	buyer_contact(s), tab

	, check(buyer_contact(end) < -280 )

	, trace([ `buyer contact`, buyer_contact ])

	, check( i_user_check( gen_string_to_upper, buyer_contact, CU  ) )

	, buyer_contact( CU )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_net_total_number, [
%=======================================================================

	 q0n(anything)

	,`Totale`, `a`, `corpo`, `iva`, `esclusa`, `:`, tab

	, q10( `€` ), total_net(d)

	, newline

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	q0n(anything)

	,`Totale`, `a`, `corpo`, `iva`, `esclusa`, `:`, tab

	, q10( `€` ), total_invoice(d)

	, newline

	, trace( [ `total invoice`, total_invoice ] )	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line

	, q10(get_first_invoice_line)

	, q10([ line_quantity_line, line_item_line ])

	, q10([ line_item_line, line_quantity_line ])

	, q10([ line_quantity_line ])

	, q10([ line_item_line ])
	
	, trace( [ `starting normal line structure run`] )
	
	, qn0( [ peek_fails(line_end_line)

		, or([ 

			[ get_line_invoice, line_quantity_line, q10(line_item_line) ]

			, [ get_line_invoice, line_item_line, q10(line_quantity_line) ]

			, [ get_line_invoice_2, q10(line_item_line) ]

			, line

		] ) ])

] ).


%=======================================================================
i_rule( get_first_invoice_line, [
%=======================================================================
	 
	first_item_line
	
	, trace( [ `finished first item line` ] )

	, or([ [ first_invoice_line, q10(rubbish_line)
	
			, or( [ [ line_quantity_line, line_item_line ]
			
				, [ line_item_line, line_quantity_line ] 
				
			] ) 
			
		]

		, [ first_invoice_line_2, q10(rubbish_line), line_item_line ]
		
	 ])

] ).

%=======================================================================
i_line_rule_cut( rubbish_line, [ q(1,4, word), newline, trace( [ `skipped rubbish line` ] ) ]).
%=======================================================================


%=======================================================================
i_line_rule_cut( first_item_line, [ 
%=======================================================================

	  q10( generic_item( [ line_item_for_buyer, w, tab ] ) )
	  
	, um(w), tab, `prezzo`

	, q0n(anything)

	, q10( generic_item( [ line_original_order_date, date ] ) )
	
	, newline

] ).


%=======================================================================
i_line_rule_cut( first_invoice_line, [
%=======================================================================
	
	 generic_item_cut( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity_1, d, tab ] )

	, q0n( [ dummy(s1), tab ] )
	
	, generic_item_cut( [ line_net_amount, d ] )

	, q10( generic_item_cut( [ line_original_order_date, date ] ) )
	
	, newline
	
	, trace( [ `finished first line` ] )

] ).


%=======================================================================
i_line_rule_cut( first_invoice_line_2, [
%=======================================================================
	
	 generic_item_cut( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, q0n( [ dummy(s1), tab ] )
	
	, generic_item_cut( [ line_net_amount, d, [ q01(tab), generic_item( [ line_original_order_date, date, newline ] ) ] ] )

] ).



%=======================================================================
i_line_rule_cut( line_header_line, [ `cod`, `.`, `art`, `.`, q10(tab), `Descrizione` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [`Totale`, `a`, `corpo`], `segue` ] ) ] ).
%=======================================================================
i_line_rule_cut( get_line_invoice, [
%=======================================================================
	 
	  q10( [ line_item_for_buyer(w), check(line_item_for_buyer(start) < -400) 

		, trace( [ `line item for buyer`, line_item_for_buyer] )	

		, q10(tab)
	
	] )
	
	, generic_item_cut( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity_uom_code_x, w, q10(tab) ] )

	, generic_item_cut( [ line_quantity_1, d, tab ] )

	, q0n( [ dummy(s1), tab ] )
	
	, generic_item_cut( [ line_net_amount, d, [ q01(tab), generic_item( [ line_original_order_date, date, newline ] ) ] ] )

] ).



%=======================================================================
i_line_rule_cut( get_line_invoice_2, [
%=======================================================================
	 
	q10( [ line_item_for_buyer(w), check(line_item_for_buyer(start) < -400)

		, trace( [ `line item for buyer`, line_item_for_buyer] )	

		, q10(tab)
		
	] )
	
	, generic_item_cut( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity_uom_code_x, w1, q10(tab) ] )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, line_quantity_uom_code(`MISSING`) 	

	, q0n( [ dummy(s1), tab ] )
	
	, generic_item_cut( [ line_net_amount, d, [ q01(tab), generic_item( [ line_original_order_date, date, newline ] ) ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	 or( [ `cod`, `codice` ] ), or( [ `.`, `:` ] )

	, line_item(w)
	
	, trace( [ `line item`, line_item ] )

] ).


%=======================================================================
i_line_rule_cut( line_quantity_line, [
%=======================================================================

	  trace( [ `in line quantity line` ] )
	  
	, line_quantity(d), read_ahead( line_quantity_uom_code(w) ), or([ `nr`, `mt` ])
	
	, trace( [ `line_quantity`, line_quantity ] )

] ).


%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	append( line_descr(s), ` `, ``) , newline

] ).


%=======================================================================
i_rule_cut( decode_line_uom_code, [
%=======================================================================

	or([ [ `pz`, line_quantity_uom_code( `EA` ) ]

		, [ `cf`, line_quantity_uom_code( `EA` ) ]

		, [ `m`, line_quantity_uom_code( `M` ) ]

		, [ `mt`, line_quantity_uom_code( `M` ) ]

		, [ `ml`, line_quantity_uom_code( `M` ) ]

		, [ word ]

	])

] ).


