%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - ED IMPIANTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ed_impianti, `15 March 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `13009689` )                      %PROD
	]) ]

	, delivery_party(`E.D. IMPIANTI S.R.L`)

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_buyer_contact]

	, buyer_ddi(`0432733922`)
	
	, delivery_ddi(`0432733922`)

	,[q0n(line), get_order_number_date ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_delivery_date_rule

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]
	
	, get_customer_comments_rule
	
	, get_shipping_instructions_rule
	
	, get_cig_cup

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_date_rule, [
%=======================================================================

	  q0n(line), find_delivery_date_header_line
	  
	, q(0,2,line), find_delivery_date_line

] ).

%=======================================================================
i_line_rule( find_delivery_date_header_line, [ 
%=======================================================================

	  q0n(anything), `CONSEGNA`, tab

	, trace([ `delivery date found` ])

]).

%=======================================================================
i_line_rule( find_delivery_date_line, [ 
%=======================================================================

	  q0n(anything), delivery_date(date), tab

	, trace([ `delivery date:`, delivery_date ])

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CIG & CUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_cig_cup, [ 
%=======================================================================

	q(0,30,line), peek_ahead( generic_horizontal_details( [ [ `Cig`, tab, `Cup` ] ] ) )
	
	, or( [ 
		read_ahead( 
			generic_vertical_details( [ [ tab, `CIG` ], cig, s1
				, check( not( q_sys_sub_string( cig, _, _, ` ` ) ) )
			] ) 
		)
		, cig( `` ) 
	] )
		
	, or( [ 
		generic_vertical_details( [ [ tab, `CUP` ], cup, s1
				, check( not( q_sys_sub_string( cup, _, _, ` ` ) ) )
			] ) 
		, cup( `` ) 
	] )
	
	, check( cup = Cup )
	, check( cig = Cig )
	
	, check( strcat_list( [ `CIG:`, Cig, ` CUP:`, Cup ], AL ) )
	, delivery_address_line( AL )
	, trace( [ `Delivery Address Line`, delivery_address_line ] )

] ).

%=======================================================================
i_line_rule( cig_cup_line, [ 
%=======================================================================

	q(2,2,
		[ q0n(anything)
			, or( [ [ peek_fails( test( got_cig ) ), `CIG`, cig(w), set( got_cig ) ]
			
				, [ peek_fails( test( got_cup ) ), `CUP`, cup(w), set( got_cup ) ]
			] )
		]
	)	

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions_rule, [
%=======================================================================

	  q0n(line), find_shipping_header_line
	  
	, q(0,2,line), find_shipping_instructions_line

] ).

%=======================================================================
i_line_rule( find_shipping_header_line, [ 
%=======================================================================

	  `CANTIERE`, or( [ tab, newline ] )

	, trace([ `shipping header found` ])

]).

%=======================================================================
i_line_rule( find_shipping_instructions_line, [ 
%=======================================================================

	  read_ahead( [shipping_instructions(s1), tab ] )
	  
	, customer_comments(s1), tab

	, trace([ `shipping instructions`, shipping_instructions ])
	
	, trace([ `customer_comments`, customer_comments ])

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

	 , delivery_address_line

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`DESTINAZIONE`,  newline

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_address_line, [ 
%=======================================================================

	delivery_street(sf), `-`

	, trace([ `delivery street`, delivery_street ])

	, delivery_postcode(d)

	, trace([ `delivery postcode`, delivery_postcode ])

	, delivery_city(s)

	, trace([ `delivery city`, delivery_city ])

	,`(`, delivery_state(w), `)`

	, trace([ `delivery state`, delivery_state ])

	, newline
	
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	get_buyer_contact_first

	, q(0,2,line)

	, get_buyer_contact_second
	
	, pagamento_line

] ).

%=======================================================================
i_line_rule( get_buyer_contact_first, [ 
%=======================================================================

	`ATTENZIONE`, `:`, `NON`, `SI`, `ACCETTANO`

	, q0n(anything)

	, read_ahead(buyer_contact(w))
	
	, check( buyer_contact(start) > 190 )
	
	, check( buyer_contact(y) > 350 )

	, delivery_contact(w), tab

	, dummy(s1)

	, newline

	, trace( [ `buyer contact`, buyer_contact ] )

	, trace( [ `delivery contact`, delivery_contact ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_contact_second, [ 
%=======================================================================

	trace( [ `inside rule` ] ) 
	 
	, q0n(anything)
	
	, read_ahead( dummy_name(w) )
	
	, check( dummy_name(start) > 180 )

	, read_ahead(append(buyer_contact(w), ` `, ``))

	, append(delivery_contact(w), ` `, ``), tab

	, dummy(s1)

	, newline

	, trace( [ `buyer contact`, buyer_contact ] ) 

	, trace( [ `delivery contact`, delivery_contact ] ) 

] ).

%=======================================================================
i_line_rule( pagamento_line, [ 
%=======================================================================

	  `PAGAMENTO`, newline
	  
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

	, q10( line )

	, get_order_number_date_line

] ).

%=======================================================================
i_line_rule( get_order_number_date_header, [ 
%=======================================================================

	`ORDINE`, `N`, `.`, q10( tab ), `DATA`

	, trace( [ `order number header found` ] ) 

] ).

%=======================================================================
i_line_rule( get_order_number_date_line, [ 
%=======================================================================

	order_number(s)
	
	, q01( [ tab, append( order_number(w), ``, `` ) ] )
	
	, q01( tab )

	, trace( [ `order number`, order_number ] ) 

	, generic_item( [ invoice_date, date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	total_net(`0`)
	
	, total_invoice(`0`)

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

		, or([ line_invoice_line, line_defect_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Codice`, tab, `Descrizione`, tab, `UM` ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`DESTINAZIONE`,  newline

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	read_ahead(line_item_for_buyer(s1))

	, trace([ `line item for buyer`, line_item_for_buyer ])

	, or( [ line_item( f( [ q(alpha("HIL"),3,3), begin, q(dec,4,10), end ] ) )
	
		, [ q10([ `hi`, `*` ]), line_item(s1) ]
		
	] ), tab

	, trace( [ `line item`, line_item ] )

	, generic_item_cut( [ line_descr, s, [ q10( tab ), check( line_descr(end) < 190 ) ] ] )

	, line_quantity_uom_code(s), q10( tab )

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, line_quantity(d)

	, trace([ `line quantity`, line_quantity ])

	, tab, line_unit_amount_x(d)
	
	, line_unit_amount(`0`)
	
	, newline

	, trace( [ `line unit amount`, line_unit_amount ] )
	
	, q10( [ with( invoice, delivery_date, DELIVERY_DATE )
	
	, line_original_order_date( DELIVERY_DATE ) ] )

	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_line_rule_cut( line_defect_line, [
%=======================================================================

	 or( [ [ `hi`, `*` ]
	 
		, item( f( [ q(alpha("HIL"),3,3), begin, q(dec,4,10), end ] ) )
		
	] )

	, force_result(`defect`)

] ).