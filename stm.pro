%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - STM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( stm, `08 July 2015` ).

i_date_format( `y-m-d` ).

i_user_field( invoice, second_street, `second street storage` ).

i_user_field( invoice, left_margin, `left margin` ).

i_user_field( invoice, right_margin, `right margin` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%	set(reverse_punctuation_in_numbers)

	buyer_party( `LS` )

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10450314` ) ]    %TEST
	    , suppliers_code_for_buyer( `10687256` )                      %PROD
	]) ]


%	,or([ [q0n(line), get_delivery_address_one ], [q0n(line), get_delivery_address_two ] ])
	
	, get_type_of_supply
	
	, get_delivery_address_three

%	,[q0n(line), get_street_two]

	,[q0n(line), get_buyer_contact ]

	,[q0n(line), get_buyer_ddi ]

	,[q0n(line), get_buyer_fax ]

	,[q0n(line), get_buyer_email ]

	,[q0n(line), get_delivery_contact ]

	,[q0n(line), get_delivery_ddi ]

	,[q0n(line), get_delivery_fax ]

	,[q0n(line), get_delivery_email ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_invoice_date ]

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]

	, get_total

	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TYPE OF SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_type_of_supply, [
%=======================================================================
 
	  or( [ [ q(0,30,line), type_of_supply_line ]
	  
			, [ type_of_supply( `01` ), cost_centre( `Standard` ) ]

	] )		

] ).

%=======================================================================
i_line_rule( type_of_supply_line, [
%=======================================================================
 
	  q0n(anything), `cueillette`
	  
	, type_of_supply( `04` )
	
	, cost_centre( `Collection_Cust` )
	
	, delivery_note_number( `15699882` )
	
	, set( cueillette )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address_one, [
%=======================================================================
 
	delivery_header_one

	 , q(2, 2, line)

	 , delivery_street_line_one

	 , delivery_postcode_city_line_one

] ).

%=======================================================================
i_line_rule( delivery_header_one, [ 
%=======================================================================

	  `N`, tab, `BRUT`,  newline

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_street_line_one, [ 
%=======================================================================

	q0n(anything)

	, delivery_street(d), `,`, append(delivery_street(s), ` `, ``), q10(`,`), newline

	, check(delivery_street(start) > -18 )

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
i_line_rule( delivery_postcode_city_line_one, [ 
%=======================================================================
	
	q0n(anything)

	, delivery_city(s)

	, check(delivery_city(start) > -18 )

	, trace([ `delivery city`, delivery_city ])

	, `,`

	, delivery_state(`QC`)

	, trace([ `delivery state`, delivery_state ])

	, delivery_postcode(f([ begin, q([alpha, dec], 2,4), end]))

	, append(delivery_postcode(f([ begin, q([alpha, dec], 2,4), end])), ` `, ``)

	, check(delivery_postcode(start) > -18 )

]).

%=======================================================================
i_rule( get_street_two, [ 
%=======================================================================
	
	get_street_two_header

	, line

	, get_street_two_line

	, q10(get_street_two_line_conintued)

]).

%=======================================================================
i_line_rule( get_street_two_header, [ 
%=======================================================================
	
	  `N`, tab, `BRUT`,  newline

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( get_street_two_line, [ 
%=======================================================================
	
	q0n(anything)

	, delivery_street(s), newline

	, check(delivery_street(start) > -18 )

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
i_line_rule( get_street_two_line_conintued, [ 
%=======================================================================
	
	q0n(anything)

	, read_ahead([`VOIE`, `)`])

	, append(delivery_street(s), ` `, ``), newline

	, check(delivery_street(start) > -18 )

	, trace([ `delivery street`, delivery_street ])

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS TWO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address_two, [
%=======================================================================
 
	delivery_header_two

	 , q(0, 3, line)

	 , delivery_street_line_two

	 , delivery_postcode_city_line_two

] ).

%=======================================================================
i_line_rule( delivery_header_two, [ 
%=======================================================================

	  `N`, tab, `BRUT`,  newline

	, trace([ `delivery header found` ])

]).

%=======================================================================
i_line_rule( delivery_street_line_two, [ 
%=======================================================================

	q0n(anything)

	, delivery_street(d), append(delivery_street(s), ` `, ``), `,`

	, delivery_city(s), `,`

	, delivery_postcode(f([ begin, q([alpha, dec], 2,4), end]))

	, append(delivery_postcode(f([ begin, q([alpha, dec], 2,4), end])), ` `, ``)

	, newline

	, check(delivery_street(start) > -18 )

	, trace([ `delivery street`, delivery_street ])

]).

%=======================================================================
i_line_rule( delivery_postcode_city_line_two, [ 
%=======================================================================
	
	q0n(anything)

	, append(delivery_postcode(s), ` `, ``)

	, check(delivery_postcode(start) > -18 )

	, delivery_state(`QC`)

	, trace([ `delivery state`, delivery_state ])

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS THREE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address_three, [
%=======================================================================
 
	  peek_fails( test( cueillette ) )
	  
	, delivery_party(`SOCIETE DE TRANSPORT MTL`)
		
	, delivery_state( `QC` )
	  
	, q0n(line)
	  
	, delivery_header_three

	, q(0,3,line)
	
	, delivery_header_two
	 
	, get_line_coordinates_line( [ LEFT, LEFT_2, RIGHT ] )
	 
	, get_second_street_rule( [ LEFT ] )

	, line_delivery_address_line( 2, LEFT_2, RIGHT, [ LEFT ] )

] ).

%=======================================================================
i_rule( get_second_street_rule( [ LEFT ] ), [ 
%=======================================================================

	 or( [ [ read_ahead( [ line, line_voie_line( [ LEFT ] ) ] )
	  
			, get_second_street_line( [ LEFT ] )
			
			, get_second_street_line_extra( [ LEFT ] )
			
			]
			
			, [ get_second_street_line( [ LEFT ] )
			
				, q01( get_second_street_line_extra( [ LEFT ] ) )
				
			]
			
		] )

] ).

%=======================================================================
i_line_rule( line_voie_line( [ LEFT ] ), [ 
%=======================================================================

	  nearest_word( LEFT, 5, 10 )
	  
	, q0n(word), `)`
	
	, trace( [ `found the bracket` ] )

] ).

%=======================================================================
i_line_rule( get_second_street_line( [ LEFT ] ), [ 
%=======================================================================

	  nearest_word( LEFT, 5, 10 )
	  
	, second_street(s1)
	  
	, trace( [ `second street`, second_street ] )

] ).

%=======================================================================
i_line_rule( get_second_street_line_extra( [ LEFT ] ), [ 
%=======================================================================

	  nearest_word( LEFT, 5, 10 )
	  
	, append( second_street(s1), ` `, `` )
	  
	, trace( [ `appended second street`, second_street ] )

] ).

%=======================================================================
i_line_rule( delivery_header_three, [ 
%=======================================================================

	  q0n(anything)
	  
	, `Produit`, `/`, description(w), tab
	
	, address(s1), tab

] ).

%=======================================================================
i_line_rule_cut( get_line_coordinates_line( [ LEFT, LEFT_2, RIGHT ] ), [ 
%=======================================================================

	  nearest_word( address(start), 20, 10 )
	  
	, nearly_left_margin(s1), tab
	
	, trace( [ `left margin found?`, nearly_left_margin ] )
	
	, check( i_user_check( gen_add, nearly_left_margin(start), 5, LEFT ) )

	,  check( i_user_check( gen_subtract, nearly_left_margin(start), 5, LEFT_2 ) )
	
	, left_margin( LEFT )
	
	, right_margin(s1), tab
	
	, check( i_user_check( gen_same, right_margin(start), RIGHT ) )
	
	, trace( [ `right`, RIGHT ] )
	
	, trace( [ `left`, left_margin ] )

] ).

%=======================================================================
i_line_rule( line_delivery_address_line( [ LEFT ] ), [ 
%=======================================================================

	  nearest_word( LEFT, 5, 10 )
	  
	, or( [ [ `8845`
	
			, delivery_street( `8845, BOUL. SAINT-LAURENT` )
			
			, delivery_city( `Montreal` )
			
			, delivery_postcode( `H2N1M3` )
			
			, trace( [ `Fixed address` ] )
			
		]
		
		, [ or( [ [ read_ahead( [ word, `,` ] )
	
					, delivery_street(sf)
					
					, read_ahead( [ dummy(s1), trace( [ `dummy`, dummy ] ) ] )
					
					, or( [ 
					
							[ read_ahead( [ `,`
							
								, or( [ [ `Saint`, `-`, `Laurent` ]
						
									, [ `St`, `-`, `Laurent` ]

									, [ city(w), check( i_user_check( trading_city, city ) ) ]

								] )

							] )
					
							, `,`

						]
				

						, read_ahead( [ 
						
							or( [ [ `Saint`, `-`, `Laurent` ]
					
								, [ `St`, `-`, `Laurent` ]

								, [ city(w), trace( [ `city trial`, city ] ), check( i_user_check( trading_city, city ) ), trace( [ `found city`, city ] ) ]

							] )

						] )

					] )
				
				]

				, [ delivery_street(sf), `,` ]
				
			] )

			, trace( [ `delivery street`, delivery_street ] )

			, delivery_city(sf), `,`

			, trace( [ `delivery city`, delivery_city ] )

			, set(regexp_allow_partial_matching)

			, delivery_postcode( f( [ begin, q(alpha,1,1), q(dec,1,1), q(alpha,1,1), end ] ) )

			, append( delivery_postcode( f( [ begin, q(dec,1,1), q(alpha,1,1), q(dec,1,1), end ] ) ), ``, `` )

			, clear(regexp_allow_partial_matching)

			, trace( [ `delivery_postcode`, delivery_postcode ] )

		]
		
	] )

	, with( invoice, second_street, SECOND )

	, delivery_dept( SECOND )

	, trace( [ `moved second street to dept`, SECOND ] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	`ACHETEUR`, `:`

	, buyer_contact(s1)

	, trace( [ `buyer contact`, buyer_contact] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	or([`TÉL`, `Tél`]), `:`

	, buyer_ddi(s)

	, check(buyer_ddi(y) > 155 )

	,`Fax`, `:`

	, trace( [ `buyer ddi`, buyer_ddi ] )


] ).

%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	q0n(anything)

	,`Fax`, `:`

	, buyer_fax(s1)

	, check(buyer_fax(y) > 155 )

	, trace( [ `buyer fax`, buyer_fax ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything)

	,`email`, `:`

	, buyer_email(s1)

	, check(buyer_email(end) < 0 )

	, trace( [ `buyer email`, buyer_email ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	`ACHETEUR`, `:`

	, delivery_contact(s1)

	, trace( [ `delivery contact`, delivery_contact] ) 

] ).

%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================

	or([`TÉL`, `Tél`]), `:`

	, delivery_ddi(s)

	, check(delivery_ddi(y) > 155 )

	,`Fax`, `:`

	, trace( [ `delivery ddi`, delivery_ddi ] )


] ).

%=======================================================================
i_line_rule( get_delivery_fax, [ 
%=======================================================================

	q0n(anything)

	,`Fax`, `:`

	, delivery_fax(s1)

	, check(delivery_fax(y) > 155 )

	, trace( [ `delivery fax`, delivery_fax ] ) 

	, newline

] ).

%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	q0n(anything)

	,`email`, `:`

	, delivery_email(s1)

	, check(delivery_email(end) < 0 )

	, trace( [ `delivery email`, delivery_email ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything), `LES`, `FACTURES`, `,`, `COLIS`, `ET`, tab

	, order_number(s1)

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

	or([ [`ÉMISE`, `LE`], [`date`, `:`] ])

	, invoice_date(date)

	, trace( [ `order date`, invoice_date ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`S`, `-`, `TOTAL`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

	, newline

] ).

%=======================================================================
i_rule( get_total, [
%=======================================================================

	without(total_net)
	
	, q0n(line)
	
	, up, up
	
	, total_2_line


] ).


%=======================================================================
i_line_rule( total_header_line, [
%=======================================================================
	
	`TOTAL`

	, newline

] ).

%=======================================================================
i_line_rule( total_2_line, [
%=======================================================================

	 read_ahead(total_invoice(d))

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

		, or([ skip_address_line
		
			, line_invoice_line
		
			, line_invoice_rule_two
			
			, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ q0n(anything), `N`, tab, `BRUT`  ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [`S`, `-`, `TOTAL`, tab ]
	
		, [`TOTAL`, newline ]
	
		, [ q0n(anything), `N`, tab, `BRUT` ]

		, [ `IMPORTANT`, tab, `COMMANDE`,  newline ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( skip_address_line, [
%=======================================================================

	  dummy(w)
	  
	, check( dummy(start) > -100 )

] ).

%=======================================================================
i_rule_cut( line_invoice_line, [
%=======================================================================

	  read_ahead( line_item_rule )
	
	, line_values_line

	, q10(line_descr_line)

	, q10(line_descr_line_two)

] ).

%=======================================================================
i_rule_cut( line_item_rule, [
%=======================================================================

	  or( [ line_item_one_line
	  
			, line_item_two_line
			
			, line_item_three_rule
			
			, line_item_four_rule
			
			, line_item_five_line
			
		] )
		
	, trace( [ `line item`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_one_line, [
%=======================================================================

	  trace( [ `trying first` ] )
	
	, get_to_description, q10( tab )
	  
	, `N`, `°`, line_item(w)
	  
] ).

%=======================================================================
i_line_rule_cut( line_item_two_line, [
%=======================================================================

	  trace( [ `trying second` ] )
	
	, get_to_description, q10( tab )
	  
	, line_item(f( [ begin, q(dec,4,10), end ] ) ) 
	  
] ).

%=======================================================================
i_rule_cut( get_to_description, [
%=======================================================================

	  q0n(anything), unite(w)
	  
	,  or([ [
	  
	 check( unite(start) > -230 )
	
	, check( unite(end) < -206 ) ]
	
	, [  check( unite(start) > -286 )
	
	, check( unite(end) < -264 ) ] ])
	
	, trace( [ `description found` ] )
	
] ).

%=======================================================================
i_rule_cut( line_item_three_rule, [
%=======================================================================

	  trace( [ `trying third` ] )
	
	, or( [ line_item_three_line
	  
			, line_item_other_three_rule
			
		] )

] ).

%=======================================================================
i_line_rule_cut( line_item_three_line, [
%=======================================================================

	  get_to_description, q10( tab )
	  
	, q0n(word), `#`, line_item(f( [ begin, q(dec,4,10), end, q(other(","), 0, 1) ] ) ) 
	  
] ).

%=======================================================================
i_rule_cut( line_item_other_three_rule, [
%=======================================================================

	  q(0,2,line)
	  
	, line_item_other_three_line
	  
] ).

%=======================================================================
i_line_rule_cut( line_item_other_three_line, [
%=======================================================================

	  q0n(word), `#`, line_item(w)
	  
] ).

%=======================================================================
i_rule_cut( line_item_four_rule, [
%=======================================================================

	  trace( [ `trying fourth` ] )
	
	, or( [ [ line_item_four_line ]
	  
			, [ q(1,3,line)
			
				, line_item_four_other_line
	  
				, line_not_description_line
				
			]
			
		] )

] ).

%=======================================================================
i_line_rule_cut( line_item_four_line, [
%=======================================================================

	  get_to_description, q10( tab )
	  
	, q0n(word), line_item(f( [ begin, q(dec,4,10), end ] ) ) 
	
	, or( [ tab
	
			, [ dummy(w)
			
				, check( dummy(start) > -18 )
			
			]
			
		] )
	  
	, check( line_item(end) < -18 )
	
	, check( line_item(start) > -206 )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_four_other_line, [
%=======================================================================

	  q0n(word), line_item(f( [ begin, q(dec,4,10), end ] ) ) 
	
	, or( [ tab
	
			, [ dummy(w)
			
				, check( dummy(start) > -18 )
			
			]
			
		] )
		
	, check( line_item(end) < -18 )
	
	, check( line_item(start) > -206 )
	  
] ).

%=======================================================================
i_line_rule_cut( line_not_description_line, [
%=======================================================================

	  dummmy(w)
	  
	, or( [ check( dummmy(end) < -300 )
	
			, check( dummmy(start) > -18 )
			
		] )
	  
] ).

%=======================================================================
i_rule_cut( line_item_five_line, [
%=======================================================================

	  trace( [ `Not found` ] )
	
	, line_item( `Missing` )
	  
] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  line_order_line_number_rule

	, q10( [ stm_rule ] )

	, line_quantity_rule

	, unite_rule

	, q10([ line_descr_rule ])

	, address_rule

	, q10( [ orderdate_rule ] )

	, unitamount_rule

	, line_net_amount_rule

	, fed_prove_rule

] ).

%=======================================================================
i_rule_cut( line_order_line_number_rule, [
%=======================================================================

	  line_order_line_number(d), q10(tab)

	, trace([ `line order line number`, line_order_line_number ])
	
] ).

%=======================================================================
i_rule_cut( stm_rule, [
%=======================================================================

	  stm(w), tab 
	
] ).

%=======================================================================
i_rule_cut( line_quantity_rule, [
%=======================================================================

	  line_quantity(d), q10(`.`), q01(tab)

	, trace([ `line quantity`, line_quantity ])
	
] ).

%=======================================================================
i_rule_cut( unite_rule, [
%=======================================================================

	  unite(w)
	
	, check( unite(end) < -207 )
	
] ).

%=======================================================================
i_rule_cut( line_descr_rule, [
%=======================================================================

	  line_descr(s)

	, check(line_descr(end) < -18 )

	, q10(tab)

	, trace([ `line description`, line_descr ])
	
] ).

%=======================================================================
i_rule( address_rule, [
%=======================================================================

	  address(s), tab, q01( [ append( address(w), ` `, `` ), q01( tab ) ] )
	  
	, trace( [ `address`, address ] )
	
] ).

%=======================================================================
i_rule_cut( orderdate_rule, [
%=======================================================================

	  orderdate(date), tab
	  
	, trace( [ `orderdate`, orderdate ] )
	
] ).

%=======================================================================
i_rule_cut( unitamount_rule, [
%=======================================================================

	  generic_item_cut( [ unitamount, d, [ q10( tab ), q10( [ `-`, num(d), `%`, tab ] ) ] ] )
	
] ).

%=======================================================================
i_rule_cut( line_net_amount_rule, [
%=======================================================================

	  line_net_amount(fd( [ begin, q([other_skip(","),dec],1,8), q(other("."),1,1), q(dec,2,2), end ] ) )
	
	, q01(tab)

	, trace([ `line net amount`, line_net_amount ])
	
] ).

%=======================================================================
i_rule_cut( fed_prove_rule, [
%=======================================================================

	  fed(d)

	, prove(d)

	, newline
	
] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	read_ahead(dummy(s))

	, check(dummy(end) < -18 )

	, append(line_descr(s), ` `, ``)

	, trace([ `line description`, line_descr ])
	

] ).

%=======================================================================
i_line_rule_cut( line_descr_line_two, [
%=======================================================================
	
	read_ahead(dummy(s))

	, check(dummy(end) < -18 )

	, append(line_descr(s), ` `, ``)

	, trace([ `line description`, line_descr ])
		

] ).

%=======================================================================
i_rule_cut( line_invoice_rule_two, [
%=======================================================================

	  read_ahead( line_item_rule )
	  
	, line_invoice_line_two
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line_two, [
%=======================================================================

	line_order_line_number(d), q10(tab)

	, trace([ `line order line number`, line_order_line_number ])

	, q10([stm(w), tab ])

	, line_quantity(d), q10(`.`)

	, trace([ `line quantity`, line_quantity ])

	, unite(w)

	, line_descr(s)

	, check(line_descr(end) < -18 )

	, tab

	, trace([ `line description`, line_descr ])

	, address(s), tab, q10([address(s), tab])

	, q10([orderdate(date), tab])

	, unitamount(d), tab

	, line_net_amount(fd( [ begin, q([other_skip(","),dec],1,8), q(other("."),1,1), q(dec,2,2), end ] ) )

	, trace([ `line net amount`, line_net_amount ])

	, fed(d)

	, prove(d)

	, newline

] ).

i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `SOCIETE DE TRANSPORT MTL` ), _, _, _, _) :- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME1, `SOCIETE DE TRANSPORT MTL` ), _, _, _, _) :- result( _, invoice, delivery_contact, NU ), string_to_upper(NU, NAME1).

%=======================================================================
% LOOKUP
%=======================================================================

i_user_check( trading_city, CITY ) 
:-
	check_the_city( CITY )
.

check_the_city( `MONTREAL` ).
check_the_city( `TERREBONNE` ).
check_the_city( `LASALLE` ).
check_the_city( `BOUCHERVILLE` ).
check_the_city( `QUEBEC` ).
check_the_city( `LAVAL` ).
check_the_city( `ANJOU` ).




