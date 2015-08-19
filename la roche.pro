%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - LA ROCHE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( la_roche, `23 May 2014` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CH-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11202554` ) ]    %TEST
	    , suppliers_code_for_buyer( `10526651` )                      %PROD
	]) ]

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	,[q0n(line), get_customer_comments ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]	

%	, total_net(`0`)

%	, total_invoice(`0`)

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

	`ALLE`, `ARTIKEL`, `LIEFERN`

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_party_line, [ 
%=======================================================================

	delivery_party(s1)

	, check(delivery_party(end) < -140 )

	, trace([ `delivery party`, delivery_party ])
	
]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s1)

	, check(delivery_street(end) < -140 )

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [ 
%=======================================================================
	
	delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s1)

	, check(delivery_city(end) < -140 )

	, trace([ `delivery city`, delivery_city ])
	
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`Preparer`, `:`, tab

	, buyer_contact(s), `,`

	, buyer_email(s), `,`

	, buyer_ddi(`0`)

	, append(buyer_ddi( f( [ q(other("+"),1,1), q(dec,2,2), begin, q(dec,9,9), end ]) ), ``, ``)

	, trace( [ `buyer contact`, buyer_contact ] )

	, trace( [ `buyer email`, buyer_email ] ) 

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	get_order_number_header

	, get_order_number_line

] ).

%=======================================================================
i_line_rule( get_order_number_header, [ 
%=======================================================================

	q0n(anything)

	,`(`, `neu`, `)`

	, newline

	, trace( [ `order number header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	q0n(anything)

	, order_number(s1)

	, check(order_number(start) > 200 )

	, newline

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

	`Bestellung`, `gesendet`, `:`

	, q0n(anything)

	, or( [ invoice_date(date)
	
			, [ invoice_date(d), `.`
			
				, invoice_month_rule, `.`
				
				, append( invoice_date(d), ``, `` )
				
			] 
	] )

	, trace( [ `order date`, invoice_date ] ) 

] ).

%=======================================================================
i_rule( invoice_month_rule, [ 
%=======================================================================

	  or( [ [ `März`, month( `03` ) ]
			
			, [ `Mai`, month( `05` ) ]
			
			, [ `Okt`, month( `10` ) ]
			
			, [ `Dez`, month( `12` ) ]
			
		] )
		
	, check( i_user_check( gen_same, month, MONTH ) )
	
	, trace( [ `month`, MONTH ] )
	
	, append( invoice_date( MONTH ), `/`, `/` )
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	get_customer_comments_header

	, get_customer_comments_line

	, get_customer_comments_line_cont

] ).

%=======================================================================
i_line_rule( get_customer_comments_header, [ 
%=======================================================================

	`ALLE`, `ARTIKEL`, `LIEFERN`

	, trace( [ `customer comments header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_customer_comments_line, [ 
%=======================================================================

	q0n(anything)

	, read_ahead(customer_comments(s1))

	, shipping_instructions(s1)

	, check(shipping_instructions(start) > 115 )

	, newline

	, trace( [ `customer comments`, customer_comments] ) 

	, trace( [ `shipping instructions`, shipping_instructions] ) 

] ).

%=======================================================================
i_line_rule( get_customer_comments_line_cont, [ 
%=======================================================================

	q0n(anything)

	, read_ahead([append(customer_comments(s1), ` `, ``)])

	, append(shipping_instructions(s1), ` `, ``)

	, newline

	, trace( [ `customer comments`, customer_comments] ) 

	, trace( [ `shipping instructions`, shipping_instructions] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`Zwischensumme`, `:`, tab

	, read_ahead( total_invoice( f( [ begin, q([other_skip("'"), dec], 0,7), q(other("."),0,1), q(dec,0,3), end ]) ) )

	, trace([`total invoice`, total_invoice])

	, total_net( f( [ begin, q([other_skip("'"), dec], 0,7), q(other("."),0,1), q(dec,0,3), end ]) ), `chf`

	, trace([`total net`, total_net])

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

		, or([ line_invoice_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `POSITIONEN`, newline ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	 `Zwischensumme`, `:`, tab

] ).

%=======================================================================
i_rule_cut( line_invoice_line, [
%=======================================================================

	 line_values_line

	, line_descr_line

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	line_order_line_number(d), tab

	, trace([ `line order line number`, line_order_line_number ])

	, line_item(s1), tab

	, trace([ `line item`, line_item ])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	, `(`, line_quantity_uom_code(w), `)`, tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, date_rule

	, trace([ `original order date`, line_original_order_date ])

	, q0n(anything)

	, line_net_amount( f( [ begin, q([other_skip("'"), dec], 1,5), q(other("."),0,1), q(dec,0,3), end, q([ alpha, dec ],0,9) ]) )
	
	, q01( dummy( f( [ begin, q(alpha,1,5), end ] ) ) )

	, trace([ `line net amount`, line_net_amount_x, dummy ])

	, newline

] ).

%=======================================================================
i_rule_cut( date_rule, [
%=======================================================================


	line_original_order_date(d), `.`

	, or([ 
	
	 [`jan`, append(line_original_order_date(`01`), ` `, ``) ]
	,[`januar`, append(line_original_order_date(`01`), ` `, ``) ]
	
	,[`fab`, append(line_original_order_date(`02`), ` `, ``) ]
	,[`feb`, append(line_original_order_date(`02`), ` `, ``) ]
	,[`februar`, append(line_original_order_date(`02`), ` `, ``) ]

	,[`märz`, append(line_original_order_date(`03`), ` `, ``) ]
	,[`m`, `!`, `rz`, append(line_original_order_date(`03`), ` `, ``) ]
	,[`mär`, append(line_original_order_date(`03`), ` `, ``) ]
	,[`mar`, append(line_original_order_date(`03`), ` `, ``) ]
	,[`maerz`, append(line_original_order_date(`03`), ` `, ``) ]
	,[`m`, `!`, `r`, append(line_original_order_date(`03`), ` `, ``) ]

	,[ `april`, append(line_original_order_date(`04`), ` `, ``) ]
	,[ `apr`, append(line_original_order_date(`04`), ` `, ``) ]

	,[ `mai`, append(line_original_order_date(`05`), ` `, ``) ]

	,[ `juni`, append(line_original_order_date(`06`), ` `, ``) ]
	,[ `jun`, append(line_original_order_date(`06`), ` `, ``) ]

	,[ `juli`, append(line_original_order_date(`07`), ` `, ``) ]
	,[ `jul`, append(line_original_order_date(`07`), ` `, ``) ]

	,[ `august`, append(line_original_order_date(`08`), ` `, ``) ]
	,[ `aug`, append(line_original_order_date(`08`), ` `, ``) ]

	,[ `september`, append(line_original_order_date(`09`), ` `, ``) ]
	,[ `sept`, append(line_original_order_date(`09`), ` `, ``) ]
	,[ `sep`, append(line_original_order_date(`09`), ` `, ``) ]

	,[ `oktober`, append(line_original_order_date(`10`), ` `, ``) ]
	,[ `okt`, append(line_original_order_date(`10`), ` `, ``) ]

	,[ `november`, append(line_original_order_date(`11`), ` `, ``) ]
	,[ `nov`, append(line_original_order_date(`11`), ` `, ``) ]

	,[ `dezember`, append(line_original_order_date(`12`), ` `, ``) ] 
	,[ `dez`, append(line_original_order_date(`12`), ` `, ``) ] 

	])

	, q10(`.`), append(line_original_order_date(d), ` `, ``)

	, trace( [ `invoice date`, line_original_order_date ] )

] ).


%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	line_descr(s1)

	, trace([ `line description`, line_descr ])

	, newline

] ).